// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart' show IterableExtension;

///
/// Params
///

class IDCheckioParams {
  final DocumentType? docType;
  final IDCheckioOrientation? orientation;
  final ConfirmationType? confirmationType;
  final bool? useHd;
  final IntegrityCheck? integrityCheck;
  final ScanBothSides? scanBothSides;
  final Extraction? sideOneExtraction;
  final Extraction? sideTwoExtraction;
  final Language? language;
  final int? manualButtonTimer;
  final FeedbackLevel? feedbackLevel;
  final CaptureMode? captureMode;
  final bool? adjustCrop;
  final FileSize? maxPictureFilesize;
  final bool? confirmAbort;
  final OnlineConfig? onlineConfig;

  IDCheckioParams(IDCheckioParamsBuilder builder)
      : docType = builder.docType,
        orientation = builder.orientation,
        confirmationType = builder.confirmationType,
        useHd = builder.useHd,
        integrityCheck = builder.integrityCheck,
        scanBothSides = builder.scanBothSides,
        sideOneExtraction = builder.sideOneExtraction,
        sideTwoExtraction = builder.sideTwoExtraction,
        language = builder.language,
        manualButtonTimer = builder.manualButtonTimer,
        feedbackLevel = builder.feedbackLevel,
        captureMode = builder.captureMode,
        adjustCrop = builder.adjustCrop,
        maxPictureFilesize = builder.maxPictureFilesize,
        confirmAbort = builder.confirmAbort,
        onlineConfig = builder.onlineConfig;

  Map<String, dynamic> toJson() => {
    if (docType != null) 'DocumentType': docType!.name() else 'DocumentType': 'DISABLED',
    if (orientation != null) 'Orientation': orientation!.name() else 'Orientation': 'LANDSCAPE',
    if (confirmationType != null) 'ConfirmType': confirmationType!.name() else 'ConfirmType': 'NONE',
    if (useHd != null) 'UseHd': useHd else 'UseHd': false,
    if (integrityCheck != null)
      'IntegrityCheck': integrityCheck!.toJson()
    else
      'IntegrityCheck': {
        'ReadEmrtd': false
      },
    if (scanBothSides != null) 'ScanBothSides': scanBothSides!.name() else 'ScanBothSides': 'DISABLED',
    if (sideOneExtraction != null)
      'Side1Extraction': sideOneExtraction!.toJson()
    else
      'Side1Extraction': {
        'DataRequirement': 'DISABLED',
        'FaceDetection': 'DISABLED',
      },
    if (sideTwoExtraction != null)
      'Side2Extraction': sideTwoExtraction!.toJson()
    else
      'Side2Extraction': {
        'DataRequirement': 'DISABLED',
        'FaceDetection': 'DISABLED',
      },
    'Language': language?.name(),
    'ManualButtonTimer': manualButtonTimer,
    'FeedbackLevel': feedbackLevel?.name(),
    'CaptureMode': captureMode?.name(),
    'AdjustCrop': adjustCrop,
    'MaxPictureFilesize': maxPictureFilesize?.name(),
    'ConfirmAbort': confirmAbort,
    if (onlineConfig != null)
      'OnlineConfig': onlineConfig!.toJson()
    else
      'OnlineConfig': {}
  };
}

class IDCheckioParamsBuilder {
  DocumentType? docType;
  IDCheckioOrientation? orientation;
  ConfirmationType? confirmationType;
  bool? useHd;
  IntegrityCheck? integrityCheck;
  ScanBothSides? scanBothSides;
  Extraction? sideOneExtraction;
  Extraction? sideTwoExtraction;
  Language? language;
  int? manualButtonTimer;
  FeedbackLevel? feedbackLevel;
  bool? adjustCrop;
  FileSize? maxPictureFilesize;
  CaptureMode? captureMode;
  String? token;
  bool? confirmAbort;
  OnlineConfig? onlineConfig;
}

///
/// Enum
///

enum DocumentType { DISABLED, ID, LIVENESS, A4, FRENCH_HEALTH_CARD, BANK_CHECK, OLD_DL_FR, PHOTO, VEHICLE_REGISTRATION, SELFIE }

enum IDCheckioOrientation { PORTRAIT, LANDSCAPE }

enum ConfirmationType { DATA_OR_PICTURE, CROPPED_PICTURE, NONE }

enum ScanBothSides { ENABLED, FORCED, DISABLED }

enum Codeline {
  // no requirements, no extraction
  DISABLED,
  // no requirements, extraction
  ANY,
  // require data (decoded MRZ, decoded credit card number, ...), extraction
  DECODED,
  // require valid codeline (valid MRZ checksums, valid INSEE number checksum, etc.), extraction
  VALID,
  // require that there is no codeline to accept image, no extraction
  REJECT
}

enum FaceDetection { ENABLED, DISABLED }

class Extraction {
  Codeline codeline;
  FaceDetection faceDetection;

  Extraction(this.codeline, this.faceDetection);

  Map<String, dynamic> toJson() => {
    'DataRequirement': codeline.name(),
    'FaceDetection': faceDetection.name(),
  };
}

class IntegrityCheck {
  bool? readEmrtd = false;
  bool? docLiveness = false;


  IntegrityCheck({this.readEmrtd = false, this.docLiveness});

  Map<String, dynamic> toJson() => {
    'ReadEmrtd': readEmrtd,
    'DocLiveness': docLiveness
  };
}

class OnlineConfig {
  CISType? cisType;
  bool? isReferenceDocument;
  String? folderUid;
  bool? biometricConsent;
  bool? enableManualAnalysis;

  OnlineConfig({this.cisType, this.isReferenceDocument, this.folderUid, this.biometricConsent, this.enableManualAnalysis});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = <String, dynamic>{};
    if (cisType != null) result.putIfAbsent('cisType', () => cisType!.name());
    if (isReferenceDocument != null) result.putIfAbsent('isReferenceDocument', () => isReferenceDocument);
    if (folderUid != null) result.putIfAbsent('folderUid', () => folderUid);
    if (biometricConsent != null) result.putIfAbsent('biometricConsent', () => biometricConsent);
    if (enableManualAnalysis != null) result.putIfAbsent('enableManualAnalysis', () => enableManualAnalysis);
    return result;
  }
}

enum CaptureMode { CAMERA, PROMPT, UPLOAD }

enum Language { fr, en, pl, es, ro, cs, pt, de, it, nl, ar, uk, sk, hu }

enum FeedbackLevel { ALL, GUIDELINE, ERROR }

enum FileSize { ONE_MEGA_BYTE, TWO_MEGA_BYTES, THREE_MEGA_BYTES, FOUR_MEGA_BYTES, FIVE_MEGA_BYTES, SIX_MEGA_BYTES, SEVEN_MEGA_BYTES, HEIGHT_MEGA_BYTES }

enum CISType { ID, IBAN, CHEQUE, TAX_SHEET, PAY_SLIP, ADDRESS_PROOF, CREDIT_CARD, PORTRAIT, LEGAL_ENTITY, CAR_REGISTRATION, LIVENESS, OTHER }

extension CISTypeName on CISType {
  String name() {
    return toString().split(".").last;
  }
}

extension FileSizeName on FileSize {
  String name() {
    return toString().split(".").last;
  }
}

extension FeedbackLevelName on FeedbackLevel {
  String name() {
    return toString().split(".").last;
  }
}

extension CaptureModeName on CaptureMode {
  String name() {
    return toString().split(".").last;
  }
}

extension LanguageName on Language {
  String name() {
    return toString().split(".").last;
  }
}

extension FaceDetectionName on FaceDetection {
  String name() {
    return toString().split(".").last;
  }
}

extension CodelineName on Codeline {
  String name() {
    return toString().split(".").last;
  }
}

extension ScanBothSidesName on ScanBothSides {
  String name() {
    return toString().split(".").last;
  }
}

extension ConfirmationTypeName on ConfirmationType {
  String name() {
    return toString().split(".").last;
  }
}

extension IDCheckioOrientationName on IDCheckioOrientation {
  String name() {
    return toString().split(".").last;
  }
}

extension DocumentTypeName on DocumentType {
  String name() {
    return toString().split(".").last;
  }
}

extension GetDocumentStatus on DocumentStatus {
  DocumentStatus getFromString(String? value) {
    switch (value) {
      case "valid":
        return DocumentStatus.VALID;
      case "invalid":
        return DocumentStatus.INVALID;
      default:
        return DocumentStatus.UNKNOWN;
    }
  }
}

///
/// Result
///

class IDCheckioResult {
  List<ImageResult> images = [];
  Document? document;
  OnlineContext? onlineContext;
  List<ErrorMsg> sessionInfos = [];
  ImageQualityStatus? cisImageQualityStatus;

  IDCheckioResult.fromJson(Map<String, dynamic> json) {
    document = getDocument(json['document']);
    List<dynamic> jsonImages = json['images'];
    for (Map<String, dynamic> jsonImage in jsonImages) {
      images.add(ImageResult.fromJson(jsonImage));
    }
    Map<String, dynamic>? onlineContextResult = json['onlineContext'];
    if(onlineContextResult != null) {
      onlineContext = OnlineContext.fromJson(onlineContextResult);
    }
    List<dynamic> jsonInfos = json['sessionInfos'];
    for (Map<String, dynamic> info in jsonInfos) {
      sessionInfos.add(ErrorMsg.fromJson(info));
    }
    cisImageQualityStatus = enumFromString(ImageQualityStatus.values, json['cisImageQualityStatus']);
  }

  String toJson() {
    String resultImages = "";
    for (ImageResult image in images) {
      resultImages += "${image.toJson()},";
    }
    if (resultImages.isNotEmpty) {
      resultImages = resultImages.substring(0, resultImages.length - 1);
    }
    String resultInfos = "";
    for (ErrorMsg info in sessionInfos){
      resultInfos += "${info.toJson()},";
    }
    if(resultInfos.isNotEmpty){
      resultInfos = resultInfos.substring(0, resultInfos.length - 1);
    }
    String? cisQuality;
    if(cisImageQualityStatus != null) {
      cisQuality = "\"${cisImageQualityStatus!.name()}\"";
    } else {
      cisQuality = null;
    }
    return "{\"images\":[$resultImages]," "\"document\":{${document?.toJson() ?? ""}},\"onlineContext\":${onlineContext?.toJson() ?? ""}"
        ", \"sessionInfos\":[$resultInfos], \"cisImageQualityStatus\":$cisQuality}";
  }
}

Document? getDocument(Map<String, dynamic>? json) {
  if (json != null) {
    switch (json['type']) {
      case "IdentityDocument":
        return IdentityDocument.fromJson(json);
      case "VehicleRegistrationDocument":
        return VehicleRegistrationDocument.fromJson(json);
      default:
        return null;
    }
  } else {
    return null;
  }
}

class OnlineContext {
  String? folderUid;
  String? taskUid;
  String? documentUid;
  String? referenceDocUid;
  String? referenceTaskUid;
  LivenessStatus? livenessStatus;
  List<String>? attachmentTaskUids;
  List<String>? attachmentDocumentUids;

  OnlineContext.fromJson(Map<String, dynamic> json) {
    folderUid = json['folderUid'];
    taskUid = json['taskUid'];
    documentUid = json['documentUid'];
    referenceDocUid = json['referenceDocUid'];
    referenceTaskUid = json['referenceTaskUid'];
    livenessStatus = enumFromString(LivenessStatus.values, json['livenessStatus']);
    List<dynamic>? attachmentTaskUids = json['attachmentTaskUids'];
    if (attachmentTaskUids != null) {
      this.attachmentTaskUids = [];
      for (String value in attachmentTaskUids) {
        this.attachmentTaskUids?.add(value);
      }
    }
    List<dynamic>? attachmentDocumentUids = json['attachmentDocumentUids'];
    if (attachmentDocumentUids != null) {
      this.attachmentDocumentUids = [];
      for (String value in attachmentDocumentUids) {
        this.attachmentDocumentUids?.add(value);
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = <String, dynamic>{};
    if (referenceTaskUid?.isNotEmpty == true) result.putIfAbsent('"referenceTaskUid"', () => '"$referenceTaskUid"');
    if (referenceDocUid?.isNotEmpty == true) result.putIfAbsent('"referenceDocUid"', () => '"$referenceDocUid"');
    if (taskUid?.isNotEmpty == true) result.putIfAbsent('"taskUid"', () => '"$taskUid"');
    if (documentUid?.isNotEmpty == true) result.putIfAbsent('"documentUid"', () => '"$documentUid"');
    if (folderUid?.isNotEmpty == true) result.putIfAbsent('"folderUid"', () => '"$folderUid"');
    if (livenessStatus != null) result.putIfAbsent('"livenessStatus"', () => '"${livenessStatus!.name()}"');
    if (attachmentTaskUids?.isNotEmpty == true) result.putIfAbsent('"attachmentTaskUids"', () => getJsonArray(attachmentTaskUids!));
    if (attachmentDocumentUids?.isNotEmpty == true) result.putIfAbsent('"attachmentDocumentUids"', () => getJsonArray(attachmentDocumentUids!));
    return result;
  }
}

String getJsonArray(List<String> strings) {
  String results = "";
  for (String uid in strings) {
    results += "\"$uid\",";
  }
  if (results.isNotEmpty) {
    results = results.substring(0, results.length - 1);
  }
  return "[$results]";
}

class ImageResult {
  String? source = "";
  String? cropped = "";
  String? face = "";
  ImageStatus? imageStatus = ImageStatus.QUALITY_OK;

  ImageResult.fromJson(Map<String, dynamic> json)
      : source = json['source'],
        cropped = json['cropped'],
        face = json['face'],
        imageStatus = enumFromString(ImageStatus.values, json['imageStatus']);

  String toJson() => "{\"source\":\"$source\",\"cropped\":\"$cropped\",\"face\":\"$face\",\"imageStatus\":\"${imageStatus!.name()}\"}";
}

class ErrorMsg {
  IdcheckioErrorCause cause;
  String details;
  String? message;
  IdcheckioSubCause? subCause;


  ErrorMsg.fromJson(Map<String, dynamic> json)
      : cause = enumFromString(IdcheckioErrorCause.values, json['cause']) ?? IdcheckioErrorCause.INTERNAL_ERROR,
        details = json['details'],
        message = json['message'],
        subCause = enumFromString(IdcheckioSubCause.values, json['subCause']);

  String toJson() => "{\"cause\":\"$cause\",\"details\":\"$details\",\"message\":\"$message\",\"subCause\":\"$subCause\"}";
}

enum IdcheckioErrorCause {
  /// Regroup all the integration errors. If you need to understand what you are doing wrong, please contact the CSM team with the details.
  CUSTOMER_ERROR,
  /// Regroup all the network errors that happens when the SDK fails to reach our server.
  NETWORK_ERROR,
  /// The user has done something wrong during the capture.
  USER_ERROR,
  /// Internal server error from our side.
  INTERNAL_ERROR,
  /// Regroup all the hardware/software problems that could happen during the session.
  DEVICE_ERROR,
  /// The document shown by the user is not acceptable. (Expired, rejected, ...)
  DOCUMENT_ERROR
}

extension IdcheckioErrorCauseName on IdcheckioErrorCause {
  String name() {
    return toString().split(".").last;
  }
}

enum IdcheckioSubCause {
  /// Missing permissions, permissions have been refused by user
  MISSING_PERMISSIONS,
  /// IPS session haven been cancelled by user
  CANCELLED_BY_USER,
  /// This model of document cannot be used.
  MODEL_REJECTED,
  /// The document is expired
  ANALYSIS_EXPIRED_DOC,
  /// The document is not eligible for a PVID session.
  PVID_NOT_ELIGIBLE
}

extension IdcheckioSubCauseName on IdcheckioSubCause {
  String name() {
    return toString().split(".").last;
  }
}

abstract class Document {
  String toJson(); // Abstract method
}

class IdentityDocument extends Document {
  DocumentStatus status = DocumentStatus.UNKNOWN;
  Map<IdentityDocumentField?, FieldData> fields = {};
  IdentityDocument.fromJson(Map<String, dynamic> json) {
    status = DocumentStatus.UNKNOWN.getFromString(json['status']);
    Map<String, dynamic>? jsonFields = json['fields'];
    if (jsonFields != null) {
      for (String key in jsonFields.keys) {
        fields.putIfAbsent(enumFromString(IdentityDocumentField.values, key), () => FieldData(jsonFields[key]['value']));
      }
    }
  }

  @override
  String toJson() {
    String resultFields = "";

    fields.forEach((k, v) => resultFields += "\"${k!.name()}\":${v.toJson()},");

    if (resultFields.isNotEmpty) {
      resultFields = resultFields.substring(0, resultFields.length - 1);
    }

    return "\"type\":\"IdentityDocument\",\"status\":\"${status.name()}\",\"fields\":{$resultFields}";
  }
}

class VehicleRegistrationDocument extends Document {
  DocumentStatus status = DocumentStatus.UNKNOWN;
  Map<VehicleRegistrationDocumentField?, FieldData> fields = {};
  VehicleRegistrationDocument.fromJson(Map<String, dynamic> json) {
    status = DocumentStatus.UNKNOWN.getFromString(json['status']);
    Map<String, dynamic>? jsonFields = json['fields'];
    if (jsonFields != null) {
      for (String key in jsonFields.keys) {
        fields.putIfAbsent(enumFromString(VehicleRegistrationDocumentField.values, key), () => FieldData(jsonFields[key]['value']));
      }
    }
  }

  @override
  String toJson() {
    String resultFields = "";

    fields.forEach((k, v) => resultFields += "\"${k!.name()}\":${v.toJson()},");

    if (resultFields.isNotEmpty) {
      resultFields = resultFields.substring(0, resultFields.length - 1);
    }

    return "\"type\":\"VehicleRegistrationDocument\",\"status\":\"${status.name()}\",\"fields\":{$resultFields}";
  }
}

T? enumFromString<T>(Iterable<T> values, String? value) {
  return values.firstWhereOrNull((type) => type.toString().split(".").last == value);
}

class FieldData {
  String? value;

  FieldData(this.value);

  String toJson() => "{\"value\":\"${value!.replaceAll("\n", "\\n")}\"}";
}

enum IdentityDocumentField {
  codeLine,
  birthDate,
  documentNumber,
  emitCountry,
  emitDate,
  expirationDate,
  firstNames,
  gender,
  lastNames,
  nationality,
  personalNumber,
  emitDepartement,
  docType
}

extension IdentityDocumentFieldName on IdentityDocumentField {
  String name() {
    return toString().split(".").last;
  }
}

enum VehicleRegistrationDocumentField { codeLine, documentNumber, emitCountry, firstRegistrationDate, make, model, registrationNumber, vehicleNumber, docType }

extension VehicleRegistrationDocumentFieldName on VehicleRegistrationDocumentField {
  String name() {
    return toString().split(".").last;
  }
}

enum ImageStatus {
  /// The quality of the image has been verified and is ok */
  QUALITY_OK,
  /// The quality of the image hasn't been check. The picture has been taken manually. */
  QUALITY_NOT_VERIFIED,
  /// The quality of the image has been verified and the image is blurred */
  QUALITY_ERROR_BLUR,
  /// The quality of the image has been verified and the image contains glare */
  QUALITY_ERROR_GLARE,
  /// No mrz has been found on the given image */
  NO_MRZ_FOUND,
  /// The mrz find in the document is not valid */
  INVALID_MRZ,
  /// The document find on the image is not the expected document */
  UNEXPECTED_DOCUMENT_TYPE
}

extension ImageStatusName on ImageStatus {
  String name() {
    return toString().split(".").last;
  }
}

enum DocumentStatus { VALID, INVALID, UNKNOWN }

extension DocumentStatusName on DocumentStatus {
  String name() {
    return toString().split(".").last;
  }
}

enum LivenessStatus { AVAILABLE, NO_FACE_ON_DOCUMENT, UNAVAILABLE }

extension LivenessStatusName on LivenessStatus {
  String name() {
    return toString().split(".").last;
  }
}

enum ImageQualityStatus { STATUS_OK, QUALITY_ISSUE }

extension ImageQualityStatusName on ImageQualityStatus {
  String name() {
    return toString().split(".").last;
  }
}
