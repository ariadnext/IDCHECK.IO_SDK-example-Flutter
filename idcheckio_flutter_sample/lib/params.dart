import 'package:idcheckio/idcheckio.dart';

class ParamsListItem {
  String name;
  IDCheckioParams? params;
  bool isOnline;
  bool isIps = false;
  bool upload = false;

  ParamsListItem(this.name, this.params, this.isOnline);
}

final IDCheckioParams paramsIDOffline = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.ID
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = false
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..scanBothSides = ScanBothSides.ENABLED
  ..sideOneExtraction = Extraction(Codeline.VALID, FaceDetection.ENABLED)
  ..sideTwoExtraction = Extraction(Codeline.REJECT, FaceDetection.DISABLED)
  ..language = Language.fr
  ..manualButtonTimer = 10
  ..maxPictureFilesize = FileSize.TWO_MEGA_BYTES
  ..feedbackLevel = FeedbackLevel.ALL
  ..adjustCrop = false
  ..confirmAbort = false);

final IDCheckioParams paramsIDOnline = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.ID
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..integrityCheck = IntegrityCheck(readEmrtd: true, docLiveness: true)
  ..onlineConfig = OnlineConfig(isReferenceDocument: true));

final IDCheckioParams paramsIDAnalyze = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.ID
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = false
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..scanBothSides = ScanBothSides.ENABLED
  ..sideOneExtraction = Extraction(Codeline.VALID, FaceDetection.ENABLED)
  ..sideTwoExtraction = Extraction(Codeline.REJECT, FaceDetection.DISABLED)
  ..maxPictureFilesize = FileSize.TWO_MEGA_BYTES);

final IDCheckioParams paramsLiveness = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.LIVENESS
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..confirmAbort = true);

final IDCheckioParams paramsFrenchHealthCard = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.FRENCH_HEALTH_CARD
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT);

final IDCheckioParams paramsSelfie = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.SELFIE
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT);

final IDCheckioParams paramsAddressProof = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.A4
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = true
  ..onlineConfig = OnlineConfig(cisType: CISType.ADDRESS_PROOF));

final IDCheckioParams paramsVehicleRegistration = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.VEHICLE_REGISTRATION
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..sideOneExtraction = Extraction(Codeline.DECODED, FaceDetection.DISABLED));

final IDCheckioParams paramsIban = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.PHOTO
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = true
  ..onlineConfig = OnlineConfig(cisType: CISType.IBAN));

final IDCheckioParams paramsAttachment = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.PHOTO
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = true
  ..adjustCrop = true
  ..onlineConfig = OnlineConfig(cisType: CISType.OTHER));
