package com.ariadnext.idcheckio

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Window
import androidx.fragment.app.FragmentActivity
import com.ariadnext.idcheckio.sdk.bean.IpsCustomization
import com.ariadnext.idcheckio.sdk.bean.OnlineContext
import com.ariadnext.idcheckio.sdk.component.Idcheckio
import com.ariadnext.idcheckio.sdk.component.IdcheckioView
import com.ariadnext.idcheckio.sdk.interfaces.ErrorMsg
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioInteraction
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioInteractionInterface
import com.ariadnext.idcheckio.sdk.interfaces.result.IdcheckioResult
import com.ariadnext.idcheckio.sdk.interfaces.result.ips.IpsResultCallback
import com.ariadnext.idcheckio.sdk.utils.extension.toJson

class IDCheckioActivity : FragmentActivity(), IdcheckioInteractionInterface, IpsResultCallback {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.activity_idcheckio)
        val intent = intent
        val isOnline = intent.getBooleanExtra("isOnline", false)
        val isIps =  intent.getBooleanExtra("isIps", false)
        when {
            isIps -> {
                val folderUid = intent.getStringExtra(FOLDER_UID) ?: ""
                /**
                 * You can update the IpsCustomization with a DayNightTheme to make update the colors of the sdk.
                 * You will have more information about the DayNightTheme in the Developers Guide.
                 */
                val ipsCustomization = IpsCustomization()
                Idcheckio.startIps(this, folderUid, this, ipsCustomization)
            }
            isOnline -> {
                val idcheckioView = pushIdcheckioView(intent.getStringExtra("PARAMS")!!)
                val onlineContext = intent.getStringExtra("ONLINE")?.let {
                    OnlineContext.createFrom(it)
                }
                idcheckioView.startOnline(onlineContext)
            }
            else -> {
                val idcheckioView = pushIdcheckioView(intent.getStringExtra("PARAMS")!!)
                idcheckioView.start()
            }
        }
    }

    /**
     * Retrieve the params from the json.
     * Create an [IdcheckioView], assign the parameters to the view
     * And then push the view in the fragment manager.
     * @param params a json string with all the sdk parameters
     * @return the created [IdcheckioView]
     */
    private fun pushIdcheckioView(params: String) : IdcheckioView {
        val idcheckioView = ParametersUtil.getIDCheckioViewFromCall(params)
            .listener(this)
            .build()
        supportFragmentManager.beginTransaction().replace(R.id.idcheckio_container, idcheckioView).commit()
        return idcheckioView
    }

    override fun onIdcheckioInteraction(interaction: IdcheckioInteraction, data: Any?) {
        when (interaction){
            IdcheckioInteraction.RESULT -> {
                val result = data as IdcheckioResult
                val resultIntent = Intent()
                resultIntent.putExtra("IDCHECKIO_RESULT", result.toJson())
                setResult(RESULT_OK, resultIntent)
                finish()
            }
            IdcheckioInteraction.ERROR -> {
                val error = data as? ErrorMsg
                val errorIntent = Intent()
                errorIntent.putExtra("ERROR_MSG", error?.toJson())
                setResult(RESULT_CANCELED, errorIntent)
                finish()
            }
            else -> { Log.i("IDCheckioActivity", "Interaction not used : $interaction")}
        }
    }

    override fun onIpsSessionFailure(errorMsg: ErrorMsg) {
        onIdcheckioInteraction(IdcheckioInteraction.ERROR, errorMsg)
    }

    override fun onIpsSessionSuccess() {
        // Empty success (the sdk give no result on an ips session success)
        onIdcheckioInteraction(IdcheckioInteraction.RESULT, IdcheckioResult())
    }
}