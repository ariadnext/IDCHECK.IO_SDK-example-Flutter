import Flutter
import UIKit
import IDCheckIOSDK

public class SwiftIdcheckioPlugin: NSObject, FlutterPlugin {
    var idcheckioDelegate = IdcheckioFlutterDelegate()
    private var flutterResult: FlutterResult?
    
    enum apiMethod: String {
        case activate
        case start
        case startOnline
        case analyze
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "idcheckio", binaryMessenger: registrar.messenger())
        let instance = SwiftIdcheckioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = apiMethod(rawValue: call.method) else { fatalError("unable to parse FlutterMethodCall")}
        self.flutterResult = result
        guard let args: [String: Any] = call.arguments as? [String : Any] else {
            result("iOS could not recognize flutter arguments in method: (sendParams)")
            return
        }
        switch method {
        case .activate:
            let idToken : String = args["idToken"] as? String ?? ""
            let disableAudioForLiveness : Bool = args["disableAudioForLiveness"] as? Bool ?? true
            let extractData : Bool = args["extractData"] as? Bool ?? true
            Idcheckio.shared.activate(withToken: idToken, extractData: extractData, disableAudioForLiveness: disableAudioForLiveness) { (error: IdcheckioError?) in
                if let error = error {
                    var errorName = ""
                    print(error, terminator:"", to: &errorName)
                    errorName = errorName.snakeCased().uppercased()
                    result(FlutterError(code: errorName, message: "Error on initialization :\(error.localizedDescription)", details: nil))
                } else {
                    result(nil)
                }
            }
        case .start:
            let params: SDKParams = parseParameters(params: args)
            try? Idcheckio.shared.setParams(params)
            launchSession(online: false)
        case .startOnline:
            let params: SDKParams = parseParameters(params: args["params"] as? [String : Any])
            try? Idcheckio.shared.setParams(params)
            launchSession(online: true, onlineContext: OnlineContext.from(json: args["onlineContext"] as? String ?? ""))
        case .analyze:
            let params: SDKParams = parseParameters(params: args["params"] as? [String : Any])
            try? Idcheckio.shared.setParams(params)
            Idcheckio.shared.delegate = idcheckioDelegate
            idcheckioDelegate.flutterResult = flutterResult
            let onlineContext = OnlineContext.from(json: args["onlineContext"] as? String ?? "")
            let side1 = args["side1Uri"] as! String
            let side2 = args["side2Uri"] as? String
            let uiImage1 = UIImage(contentsOfFile: side1)!
            var uiImage2: UIImage? = nil
            if (side2 != nil){
                uiImage2 = UIImage(contentsOfFile: side2!)
            }
            let isOnline = args["isOnline"] as? Bool ?? false
            let sessionType: AnalyzeSessionType = isOnline == true ? .online(context: onlineContext) : .offline
            DispatchQueue.main.async {
                Idcheckio.shared.analyze(side1Image: uiImage1, side2Image: uiImage2, sessionType: sessionType)
            }
        }
    }
    
    func parseParameters(params : [String: Any?]?) -> SDKParams{
        let sdkParams = SDKParams()
        guard let params = params else {
            return sdkParams
        }
        sdkParams.documentType = DocumentType(rawValue: (params["DocumentType"] as! String)) ?? .disabled
        sdkParams.confirmType = ConfirmationType(rawValue: (params["ConfirmType"] as! String)) ?? .none
        let integrityCheckParams = params["IntegrityCheck"] as! [String: Any?]
        let integrityCheck = IntegrityCheck()
        integrityCheck.readEmrtd = integrityCheckParams["ReadEmrtd"] as? Bool ?? false
        sdkParams.integrityCheck = integrityCheck
        sdkParams.useHD = params["UseHd"] as? Bool ?? false
        sdkParams.scanBothSides = ScanBothSides(rawValue: (params["ScanBothSides"] as! String)) ?? .disabled
        let side1 : [String: Any] = params["Side1Extraction"] as! [String: Any]
        let extractionSide1 = Extraction()
        extractionSide1.codeline = Extraction.DataRequirement(rawValue: (side1["DataRequirement"] as! String)) ?? .disabled
        extractionSide1.face = Extraction.FaceDetection(rawValue: (side1["FaceDetection"] as! String)) ?? .disabled
        sdkParams.side1Extraction = extractionSide1
        let side2 : [String: Any] = params["Side2Extraction"] as! [String: Any]
        let extractionSide2 = Extraction()
        extractionSide2.codeline = Extraction.DataRequirement(rawValue: (side2["DataRequirement"] as! String)) ?? .disabled
        extractionSide2.face = Extraction.FaceDetection(rawValue: (side2["FaceDetection"] as! String)) ?? .disabled
        sdkParams.side2Extraction = extractionSide2
        Idcheckio.shared.extraParameters.language = Language(rawValue: params["Language"] as? String ?? "")
        Idcheckio.shared.extraParameters.feedbackLevel = FeedbackLevel(rawValue: params["FeedbackLevel"] as? String ?? "") ?? .all
        Idcheckio.shared.extraParameters.maxPictureFilesize = FileSize(rawValue: params["MaxPictureFilesize"] as? String ?? "")
        Idcheckio.shared.extraParameters.adjustCrop = params["AdjustCrop"] as? Bool ?? false
        Idcheckio.shared.extraParameters.confirmAbort = params["ConfirmAbort"] as? Bool ?? false
        let onlineConfigParams = params["OnlineConfig"] as! [String: Any?]
        let onlineConfig = sdkParams.onlineConfig
        onlineConfig.isReferenceDocument = (onlineConfigParams["isReferenceDocument"] as? Bool) ?? false
        onlineConfig.checkType = CheckType(rawValue: onlineConfigParams["checkType"] as?  String ?? "") ?? .checkFull
        onlineConfig.cisType = CISDocumentType(rawValue: onlineConfigParams["cisType"] as? String ?? "") ?? nil
        onlineConfig.folderUid = (onlineConfigParams["folderUid"] as? String) ?? nil
        onlineConfig.biometricConsent = (onlineConfigParams["biometricConsent"] as? Bool) ?? nil
        onlineConfig.enableManualAnalysis = (onlineConfigParams["enableManualAnalysis"] as? Bool) ?? false
        return sdkParams
    }

    func startCompletion(error: Error?) {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        if let error = error as? IdcheckioError{
            rootViewController?.dismiss(animated: true)
            self.flutterResult?(FlutterError(code: "CAPTURE_FAILED", message: error.toJson(), details: nil))
        }
    }
    
    func resultCompletion(result: (Result<IdcheckioResult?, Error>)) {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        rootViewController?.dismiss(animated: true)
        var jsonResult = ""
        switch result {
        case .success(let result):
            if let result = result {
                jsonResult += result.toJson()
            }
        case .failure(let error):
            if let error = error as? IdcheckioError {
                flutterResult?(FlutterError(code: "CAPTURE_FAILED", message: error.toJson(), details: nil))
            }
        }
        flutterResult?(jsonResult)
    }
    
    func launchSession(online: Bool, onlineContext: OnlineContext? = nil) {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        DispatchQueue.main.async { [online] in

            let idcheckkioViewController = IdcheckioViewController()
            idcheckkioViewController.onlineContext = onlineContext
            idcheckkioViewController.isOnlineSession = online
            idcheckkioViewController.startCompletion = self.startCompletion(error:)
            idcheckkioViewController.resultCompletion = self.resultCompletion(result:)
            rootViewController?.present(idcheckkioViewController, animated: true, completion: nil)
        }
    }

    @objc class IdcheckioFlutterDelegate : NSObject, IdcheckioDelegate {
        var flutterResult: FlutterResult?
        func idcheckioFinishedWithResult(_ idcheckioResult: IdcheckioResult?, error: Error?) {
            var jsonResult = ""
            if let idcheckioResult = idcheckioResult {
                jsonResult += idcheckioResult.toJson()
            }
            else if let error = error as? IdcheckioError {
                if jsonResult.isEmpty {
                    flutterResult!(FlutterError(code: "CAPTURE_FAILED", message: error.toJson(), details: nil))
                } else {
                    jsonResult += error.toJson()
                }
            }
            flutterResult!(jsonResult)
        }
        func idcheckioDidSendEvent(interaction: IdcheckioInteraction, msg: IdcheckioMsg?) {
            //Nothing to do...jsonResult    String
        }
    }
}

extension String {
    func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return (regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased())!
    }
}

extension IdcheckioResult {
    func toJson() -> String {
        if let jsonData = try? JSONEncoder().encode(self) {
            return String(data: jsonData, encoding: .utf8) ?? ""
        } else {
            return "{}"
        }
    }
}

extension IdcheckioError {
    func toJson() -> String {
        var type = ""
        print(self, terminator:"", to: &type)
        type = type.snakeCased().uppercased()
        return String(format: "%@%@%@%@%@%@%@", "{\"type\":\"", type, "\",\"code\":", getCode() ?? "null", ", \"message\":\"", localizedDescription, "\"}")
    }
    
    func getCode() -> Int? {
        switch self {
        case .internalError(let code):
            return code
        default:
            return nil
        }
    }
}
