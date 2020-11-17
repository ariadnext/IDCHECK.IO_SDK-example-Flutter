package com.ariadnext.idcheckio

import com.ariadnext.idcheckio.sdk.bean.*
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
                .readEmrtd(json.optBoolean(READ_EMRTD, false))
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

        /* Extra parameters (optional) */
        json.opt(LANGUAGE)?.takeIf { it.toString() != "null" }?.let { idcheckioView.language(Language.valueOf(it.toString())) }
        json.opt(MANUAL_BUTTON_TIMER)?.takeIf { it.toString() != "null" }?.let { idcheckioView.manualButtonTimer(it as Int) }
        json.opt(FEEDBACK_LEVEL)?.takeIf { it.toString() != "null" }?.let { idcheckioView.feedbackLevel(FeedbackLevel.valueOf(it.toString())) }
        json.opt(ADJUST_CROP)?.takeIf { it.toString() != "null" }?.let { idcheckioView.adjustCrop(it as Boolean) }
        json.opt(MAX_PICTURE_FILESIZE)?.takeIf { it.toString() != "null" }?.let { idcheckioView.maxPictureFilesize(FileSize.valueOf(it.toString())) }
        json.opt(TOKEN)?.takeIf { it.toString() != "null" }?.let { idcheckioView.token(it.toString()) }
        json.opt(CONFIRM_ABORT)?.takeIf { it.toString() != "null" }?.let { idcheckioView.confirmAbort(it as Boolean) }
        return idcheckioView
    }

    fun getCisContextFromJson(jsonString: String?): CISContext {
        jsonString?.takeIf { it != "null" } ?: return CISContext(null,null, null)
        val json = JSONObject(jsonString)
        val folderUid = json.optString(folderUid).takeIf { it.isNotEmpty() }
        val referenceDocUid = json.optString(referenceDocUid).takeIf { it.isNotEmpty() }
        val referenceTaskUid = json.optString(referenceTaskUid).takeIf { it.isNotEmpty() }
        val cisType = json.optString(cisType).takeIf { it.isNotEmpty() }?.let { CISType.valueOf(it) }
        val biometricConsent = if(json.has(biometricConsent)) json.getBoolean(biometricConsent) else null
        return CISContext(folderUid, referenceTaskUid, referenceDocUid, cisType, biometricConsent)
    }
}