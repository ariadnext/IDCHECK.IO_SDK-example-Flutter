import 'package:idcheckio/idcheckio.dart';

class ParamsListItem {
  String name;
  IDCheckioParams params;
  bool isOnline;
  bool upload = false;
  CISType cisType;

  ParamsListItem(this.name, this.params, this.isOnline);
}

final IDCheckioParams paramsID = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.ID
  ..orientation = IDCheckioOrientation.LANDSCAPE
  ..readEmrtd = true
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

final IDCheckioParams paramsIDAnalyze = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.ID
  ..orientation = IDCheckioOrientation.LANDSCAPE
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
  ..orientation = IDCheckioOrientation.LANDSCAPE);

final IDCheckioParams paramsSelfie = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.SELFIE
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT);

final IDCheckioParams paramsAddressProof = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.A4
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = true);

final IDCheckioParams paramsVehicleRegistration = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.VEHICLE_REGISTRATION
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.LANDSCAPE
  ..sideOneExtraction = Extraction(Codeline.DECODED, FaceDetection.DISABLED));

final IDCheckioParams paramsIban = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.PHOTO
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = true);

final IDCheckioParams paramsAttachment = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.PHOTO
  ..confirmationType = ConfirmationType.DATA_OR_PICTURE
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..useHd = true
  ..adjustCrop = true);
