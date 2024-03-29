package com.example.idcheckio

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.ariadnext.idcheckio.sdk.bean.OnlineContext
import com.ariadnext.idcheckio.sdk.component.Idcheckio
import com.ariadnext.idcheckio.sdk.interfaces.ErrorMsg
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioCallback
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioErrorCause
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioInteraction
import com.ariadnext.idcheckio.sdk.interfaces.IdcheckioInteractionInterface
import com.ariadnext.idcheckio.sdk.interfaces.result.IdcheckioResult
import com.ariadnext.idcheckio.sdk.utils.extension.toJson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** IdcheckioPlugin */
class IdcheckioPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity
  private var call: MethodCall? = null
  private var result: Result? = null

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    this.result = result
    when (call.method) {
      // IDCheck.io SDK activation
      // This have to be called before starting any session.
      ACTIVATE -> {
        this.call = call
        Idcheckio.activate(
          idToken = call.argument<String?>(IDTOKEN) ?: "",
          context = context,
          callback = idcheckioCallback,
          extractData = call.argument<Boolean>(EXTRACT_DATA) ?: true
        )
      }
      START -> {
        val intent = Intent(activity, IdcheckioActivity::class.java)
        intent.putExtra("PARAMS", call.arguments.toString())
        intent.putExtra("isOnline", false)
        activity.startActivityForResult(intent, START_REQUEST)
      }
      START_ONLINE -> {
        val intent = Intent(activity, IdcheckioActivity::class.java)
        intent.putExtra("PARAMS", call.argument<String?>(PARAMS).toString())
        call.argument<String?>(ONLINE_CONTEXT)?.let { intent.putExtra("ONLINE", it) }
        intent.putExtra("isOnline", true)
        activity.startActivityForResult(intent, START_REQUEST)
      }
      START_IPS -> {
        val folderUid = call.argument<String?>(FOLDER_UID)
        if(folderUid == null) {
          result.error("CUSTOMER_ERROR", ErrorMsg(cause = IdcheckioErrorCause.CUSTOMER_ERROR, details = "MISSING_FOLDER_UID", message = "The ips folderUid is mandatory to start an ips session.").toJson(), null)
        } else {
          val intent = Intent(activity, IdcheckioActivity::class.java)
          intent.putExtra(FOLDER_UID, folderUid)
          intent.putExtra("isIps", true)
          activity.startActivityForResult(intent, START_REQUEST)
        }
      }
      ANALYZE -> {
        val params = ParametersUtil.getIDCheckioViewFromCall(call.argument<String?>(PARAMS).toString()).captureParams()
        val isOnline = call.argument<Boolean?>(IS_ONLINE) ?: false
        val onlineContext = call.argument<String?>(ONLINE_CONTEXT)?.let { OnlineContext.createFrom(it) }
        var side1Uri = call.argument<String?>(SIDE_1_URI)
        var side2Uri = call.argument<String?>(SIDE_2_URI)
        //We can't access an internal file if the URI doesn't start by file://
        side1Uri?.let {
          if(it.startsWith("/data")){
            side1Uri = "file://$side1Uri"
          }
        }
        side2Uri?.let {
          if(it.startsWith("/data")){
            side2Uri = "file://$side2Uri"
          }
        }
        Idcheckio.analyze(
          context = context,
          captureParams = params,
          callback = idcheckioInteractionInterface,
          onlineContext = onlineContext,
          isOnline = isOnline,
          side1ToUpload = Uri.parse(side1Uri),
          side2ToUpload = side2Uri?.let { Uri.parse(it) }
        )
      }
      else -> result.notImplemented()
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if(requestCode == START_REQUEST){
      if(resultCode == Activity.RESULT_OK){
        result?.success(data?.extras?.getString("IDCHECKIO_RESULT", "{}") ?: "{}")
      } else if (resultCode == Activity.RESULT_CANCELED) {
        result?.error("CAPTURE_FAILED", data?.extras?.getString("ERROR_MSG", "{}") ?: "{}", null)
      }
      return true
    }
    return false
  }

  private val idcheckioInteractionInterface = object : IdcheckioInteractionInterface {
    override fun onIdcheckioInteraction(interaction: IdcheckioInteraction, data: Any?) {
      //We callback has to be send on the UiThread
      activity.runOnUiThread {
        when (interaction) {
          IdcheckioInteraction.RESULT -> {
            val idcheckioResult = data as IdcheckioResult
            result?.success(idcheckioResult.toJson())
          }
          IdcheckioInteraction.ERROR -> {
            val error = data as? ErrorMsg
            result?.error("CAPTURE_FAILED", error?.toJson() ?: "{}", null)
          }
          else -> {
            Log.i("IDCheckioActivity", "Interaction not used : $interaction")
          }
        }
      }
    }
  }

  private val idcheckioCallback = object : IdcheckioCallback {
    override fun onInitEnd(success: Boolean, error: ErrorMsg?) {
      if(success){
        /* Activation is OK */
        result?.success(null)
      } else {
        /* Activation is KO */
        result?.error("INIT_FAILED", error?.toJson() ?: "{}", null)
      }
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "idcheckio")
    context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @Suppress("DEPRECATION", "UNUSED")
    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
      val channel = MethodChannel(registrar.messenger(), "idcheckio")
      channel.setMethodCallHandler(IdcheckioPlugin())
    }

    const val START_REQUEST = 5
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    /*Do nothing here*/
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    /*Do nothing here*/
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    /*Do nothing here*/
  }
}
