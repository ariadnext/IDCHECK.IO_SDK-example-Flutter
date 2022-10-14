package com.example.idcheckio

import com.ariadnext.idcheckio.sdk.bean.ConfirmationType
import com.ariadnext.idcheckio.sdk.bean.DataRequirement
import com.ariadnext.idcheckio.sdk.bean.DocumentType
import com.ariadnext.idcheckio.sdk.bean.Extraction
import com.ariadnext.idcheckio.sdk.bean.FaceDetection
import com.ariadnext.idcheckio.sdk.bean.FeedbackLevel
import com.ariadnext.idcheckio.sdk.bean.FileSize
import com.ariadnext.idcheckio.sdk.bean.Forceable
import com.ariadnext.idcheckio.sdk.bean.IntegrityCheck
import com.ariadnext.idcheckio.sdk.bean.Language
import com.ariadnext.idcheckio.sdk.bean.OnlineConfig
import com.ariadnext.idcheckio.sdk.bean.Orientation
import com.ariadnext.idcheckio.sdk.component.IdcheckioView
import com.ariadnext.idcheckio.sdk.interfaces.cis.CISType
import org.json.JSONObject

object ParametersUtil {
    fun getIDCheckioViewFromCall(jsonString: String) : IdcheckioView.Builder{
        val json = JSONObject(jsonString)
        val idcheckioView = IdcheckioView.Builder()
            .docType(DocumentType.valueOf(json.optString(DOCUMENT_TYPE, DocumentType.DISABLED.name)))
            .orientation(Orientation.valueOf(json.optString(ORIENTATION, Orientation.LANDSCAPE.name)))
            .confirmType(ConfirmationType.valueOf(json.optString(CONFIRM_TYPE, ConfirmationType.NONE.name)))
            .integrityCheck(json.optJSONObject(INTEGRITY_CHECK) ?.let {
                IntegrityCheck(readEmrtd = it.optBoolean(READ_EMRTD), docLiveness = it.optBoolean(DOC_LIVENESS))
            } ?: IntegrityCheck.none())
            .useHd(json.optBoolean(USE_HD, false))
            .scanBothSides(Forceable.valueOf(json.optString(SCAN_BOTH_SIDES, Forceable.DISABLED.name)))
            .sideOneExtraction(json.optJSONObject(SIDE_1_EXTRACTION)?.let {
                Extraction(codeline = DataRequirement.valueOf(it.optString(DATA_REQUIREMENT, DataRequirement.DISABLED.name)),
                    face = FaceDetection.valueOf(it.optString(FACE_DETECTION, FaceDetection.DISABLED.name)))
            } ?: Extraction(DataRequirement.DISABLED, FaceDetection.DISABLED))
            .sideTwoExtraction(json.optJSONObject(SIDE_2_EXTRACTION)?.let {
                Extraction(codeline = DataRequirement.valueOf(it.optString(DATA_REQUIREMENT, DataRequirement.DISABLED.name)),
                    face = FaceDetection.valueOf(it.optString(FACE_DETECTION, FaceDetection.DISABLED.name)))
            } ?: Extraction(DataRequirement.DISABLED, FaceDetection.DISABLED))
            .onlineConfig(json.optJSONObject(ONLINE_CONFIG)?.let {
                OnlineConfig(isReferenceDocument = it.optBoolean(IS_REFERENCE_DOC),
                    cisType = it.optString(CIS_TYPE).takeIf { type -> type.isNotEmpty() }?.let { type -> CISType.valueOf(type) },
                    folderUid = it.optString(FOLDER_UID).takeIf { folder -> folder.isNotEmpty() },
                    biometricConsent = it.opt(BIOMETRIC_CONSENT)?.takeIf { consent -> consent.toString() != "null" }?.let { consent -> consent as Boolean },
                    enableManualAnalysis = it.optBoolean(ENABLE_MANUAL_ANALYSIS))
            } ?: OnlineConfig())

        /* Extra parameters (optional) */
        json.opt(LANGUAGE)?.takeIf { it.toString() != "null" }?.let { idcheckioView.language(Language.valueOf(it.toString())) }
        json.opt(MANUAL_BUTTON_TIMER)?.takeIf { it.toString() != "null" }?.let { idcheckioView.manualButtonTimer(it as Int) }
        json.opt(FEEDBACK_LEVEL)?.takeIf { it.toString() != "null" }?.let { idcheckioView.feedbackLevel(FeedbackLevel.valueOf(it.toString())) }
        json.opt(ADJUST_CROP)?.takeIf { it.toString() != "null" }?.let { idcheckioView.adjustCrop(it as Boolean) }
        json.opt(MAX_PICTURE_FILESIZE)?.takeIf { it.toString() != "null" }?.let { idcheckioView.maxPictureFilesize(FileSize.valueOf(it.toString())) }
        json.opt(CONFIRM_ABORT)?.takeIf { it.toString() != "null" }?.let { idcheckioView.confirmAbort(it as Boolean) }
        return idcheckioView
    }
}