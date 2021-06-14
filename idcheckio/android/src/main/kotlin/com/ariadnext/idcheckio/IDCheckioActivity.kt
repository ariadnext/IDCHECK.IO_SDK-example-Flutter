package com.ariadnext.idcheckio

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.Window
import androidx.fragment.app.FragmentActivity
import com.ariadnext.idcheckio.sdk.bean.OnlineContext
import com.ariadnext.idcheckio.sdk.interfaces.ErrorMsg
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioError
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioInteraction
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioInteractionInterface
import com.ariadnext.idcheckio.sdk.interfaces.result.IdcheckioResult
import com.ariadnext.idcheckio.sdk.utils.toJson

class IDCheckioActivity : FragmentActivity(), IdcheckioInteractionInterface {
    private var isOnline = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.activity_idcheckio)
        val intent = intent
        isOnline = intent.getBooleanExtra("isOnline", false)
        val idcheckioView = ParametersUtil.getIDCheckioViewFromCall(intent.getStringExtra("PARAMS")!!)
                .listener(this)
                .build()
        supportFragmentManager.beginTransaction().replace(R.id.idcheckio_container, idcheckioView).commit()
        if(isOnline){
            val onlineContext = intent.getStringExtra("ONLINE")?.let {
                OnlineContext.createFrom(it)
            }
            idcheckioView.startOnline(onlineContext)
        } else {
            idcheckioView.start()
        }
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
}