import Flutter
import UIKit
import IDCheckIOSDK

public class SwiftIdcheckioPlugin: NSObject, FlutterPlugin {
    var idcheckioDelegate = IdcheckioFlutterDelegate()
    private var result: FlutterResult?
    let ACTIVATE = "activate"
    let START = "start"
    let START_ONLINE = "startOnline"
    let ANALYZE = "analyze"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "idcheckio", binaryMessenger: registrar.messenger())
        let instance = SwiftIdcheckioPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Idcheckio.shared.delegate = idcheckioDelegate
        self.result = result
        guard let args: [String: Any] = call.arguments as? [String : Any] else {
            result("iOS could not recognize flutter arguments in method: (sendParams)")
            return
        }
        switch call.method {
        case ACTIVATE:
            let licenceFilename : String = args["license"] as? String ?? ""
            let disableAudioForLiveness : Bool = args["disableAudioForLiveness"] as? Bool ?? true
            let environment : SDKEnvironment = SDKEnvironment.init(rawValue: (args["environment"] as? String ?? "PROD").lowercased()) ?? .prod
            let extractData : Bool = args["extractData"] as? Bool ?? true
            Idcheckio.shared.activate(withLicenseFilename: licenceFilename, extractData: extractData, disableAudioForLiveness: disableAudioForLiveness, sdkEnvironment: environment) { (error: IdcheckioError?) in
                if let error = error {
                    var errorName = ""
                    print(error, terminator:"", to: &errorName)
                    errorName = errorName.snakeCased().uppercased()
                    result(FlutterError(code: errorName, message: "Error on initialization :\(error.localizedDescription)", details: nil))
                } else {
                    result(nil)
                }
            }
            break;
        case START:
            idcheckioDelegate.result = result
            let params: SDKParams = parseParameters(params: args)
            try? Idcheckio.shared.setParams(params)
            launchSession(online: false)
            break;
        case START_ONLINE:
            idcheckioDelegate.result = result
            let params: SDKParams = parseParameters(params: args["params"] as? [String : Any])
            try? Idcheckio.shared.setParams(params)
            let context = parseCisContext(params: args["cisContext"] as? [String : Any])
            launchSession(online: true, cisContext: context)
            break;
        case ANALYZE:
            idcheckioDelegate.result = result
            let params: SDKParams = parseParameters(params: args["params"] as? [String : Any])
            try? Idcheckio.shared.setParams(params)
            let context = parseCisContext(params: args["cisContext"] as? [String : Any])
            let side1 = args["side1Uri"] as! String
            let side2 = args["side2Uri"] as? String
            let uiImage1 = UIImage(contentsOfFile: side1)!
            var uiImage2: UIImage? = nil
            if (side2 != nil){
                uiImage2 = UIImage(contentsOfFile: side2!)
            }
            let isOnline = args["isOnline"] as? Bool ?? false
            DispatchQueue.main.async {
                Idcheckio.shared.analyze(params: params, side1Image: uiImage1, side2Image: uiImage2, online: isOnline, cisContext: context)
            }
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func parseParameters(params : [String: Any]?) -> SDKParams{
        let sdkParams = SDKParams()
        guard let params = params else {
            return sdkParams
        }
        sdkParams.documentType = DocumentType(rawValue: (params["DocumentType"] as! String)) ?? .disabled
        sdkParams.confirmType = ConfirmationType(rawValue: (params["ConfirmType"] as! String)) ?? .none
        let integrityCheck = IntegrityCheck()
        integrityCheck.readEmrtd = params["ReadEmrtd"] as? Bool ?? false
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
        
        if let language = (params["Language"] as! String).checkNotNull(){
            Idcheckio.shared.extraParameters.language = Language(rawValue: language)
        }
        if let feedbackLevel = (params["FeedbackLevel"] as! String).checkNotNull(){
            Idcheckio.shared.extraParameters.feedbackLevel = FeedbackLevel(rawValue: feedbackLevel)!
        }
        if let maxPictureFilesize = (params["MaxPictureFilesize"] as! String).checkNotNull(){
            Idcheckio.shared.extraParameters.maxPictureFilesize = FileSize(rawValue: maxPictureFilesize)
        }
        if let token = params["Token"] as? String {
            Idcheckio.shared.extraParameters.token = token
        }
        if let adjustCrop = params["AdjustCrop"] as? Bool {
            Idcheckio.shared.extraParameters.adjustCrop = adjustCrop
        }
        if let confirmAbort = params["ConfirmAbort"] as? Bool {
            Idcheckio.shared.extraParameters.confirmAbort = confirmAbort
        }
        return sdkParams
    }
    
    func parseCisContext(params : [String: Any]?) -> CISContext{
        let cisContext = CISContext()
        guard let params = params else {
            return cisContext
        }
        if let folderUid = params["folderUid"] as? String{
            cisContext.folderUid = folderUid
        }
        if let referenceTaskUid = params["referenceTaskUid"] as? String{
            cisContext.referenceTaskUid = referenceTaskUid
        }
        if let referenceDocUid = params["referenceDocUid"] as? String{
            cisContext.referenceDocUid = referenceDocUid
        }
        if let biometricConsent = params["biometricConsent"] as? Bool{
            cisContext.biometricConsent = biometricConsent
        }
        if let cisType = params["cisType"] as? String{
            cisContext.cisType = IDCheckIOSDK.CISDocumentType.init(rawValue: cisType)
        }
        return cisContext
    }

    func launchSession(online: Bool, cisContext: CISContext? = nil) {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        DispatchQueue.main.async { [weak rootViewController, online] in
            let viewController = UIViewController()
            viewController.modalPresentationStyle = .fullScreen

            let cameraView = IdcheckioView(frame: .zero)

            cameraView.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.frame = rootViewController?.view.frame ?? .zero
            viewController.view.addSubview(cameraView)
            viewController.view.backgroundColor = UIColor.black
            cameraView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
            cameraView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
            cameraView.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
            cameraView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true

            rootViewController?.present(viewController, animated: true, completion: { [rootViewController, cameraView, online] in
                if online {
                    Idcheckio.shared.startOnline(with: cameraView, cisContext: cisContext, completion: { [weak rootViewController] (error) in
                        if let error = error as? IdcheckioError{
                            rootViewController?.dismiss(animated: true)
                            self.result!(FlutterError(code: "CAPTURE_FAILED", message: error.toJson(), details: nil))
                        }
                    })
                } else {
                    Idcheckio.shared.start(with: cameraView, completion: { [weak rootViewController] (error) in
                        if let error = error as? IdcheckioError{
                            rootViewController?.dismiss(animated: true)
                            self.result!(FlutterError(code: "CAPTURE_FAILED", message: error.toJson(), details: nil))
                        }
                    })
                }
            })
        }
    }
    
    @objc class IdcheckioFlutterDelegate : NSObject, IdcheckioDelegate {
        var result: FlutterResult?
        func idcheckioFinishedWithResult(_ idcheckioResult: IdcheckioResult?, error: Error?) {
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            rootViewController?.dismiss(animated: true)
            var jsonResult = ""
            if let idcheckioResult = idcheckioResult {
                jsonResult += "{\"result\":" + idcheckioResult.toJson()
            }
            if let error = error as? IdcheckioError {
                if jsonResult.isEmpty {
                    result!(FlutterError(code: "CAPTURE_FAILED", message: error.toJson(), details: nil))
                } else {
                    jsonResult += ", \"error\":" + error.toJson()
                }
            }
            result!(jsonResult + "}")
        }

        func idcheckioDidSendEvent(interaction: IdcheckioInteraction, msg: IdcheckioMsg?) {
            //Nothing to do...
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
    
    func checkNotNull() -> String? {
        if(self != "" || self != "null"){
            return nil
        } else {
            return self
        }
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
