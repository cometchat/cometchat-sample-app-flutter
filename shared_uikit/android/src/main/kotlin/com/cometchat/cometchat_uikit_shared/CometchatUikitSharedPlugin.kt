package com.cometchat.cometchat_uikit_shared


import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.lang.Exception
import java.util.ArrayList
import java.util.HashMap
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.SimpleTarget
import com.bumptech.glide.request.transition.Transition
import android.widget.Toast
import android.provider.MediaStore
import android.os.Environment
import android.net.Uri
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat


/** CometchatUikitSharedPlugin */
class CometchatUikitSharedPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {

  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var flutterPluginBinding: FlutterPluginBinding? = null
  private lateinit var activity: Activity

  private var successCallback: Result? = null
  private var vibrator: Vibrator? = null
  private val VIBRATE_PATTERN = longArrayOf(0, 1000, 1000)

  private var delegate: CometChatFilePickerDelegate? = null
  private var isMultipleSelection = false
  private var withData = false
  private var activityBinding: ActivityPluginBinding? = null
  private var fileType: String? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding

    this.context = flutterPluginBinding.applicationContext

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cometchat_uikit_shared")
    EventChannel(flutterPluginBinding.binaryMessenger,"cometchat_uikit_shared_audio_intensity").setStreamHandler(AudioRecorderEventHandler)
    channel.setMethodCallHandler(this)
  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "playCustomSound" -> playCustomSound(call, result)
      "open_file" -> openFile(call,result)
      "stopPlayer" -> stopPlayer(result)

      "clear" -> clearCache(this.context)
      "pickFile" -> pickFile(call, result)
      "shareMessage" -> shareMessage(call, result)
      "startRecordingAudio" -> startRecordingAudio(call,result)
      "stopRecordingAudio" ->  stopRecordingAudio(call,result)
      "playRecordedAudio" -> playRecordedAudio(call,result)
      "pausePlayingRecordedAudio" -> pausePlayingRecordedAudio(call,result)
      "deleteFile" -> deleteFile(call,result)
      "releaseAudioRecorderResources" -> releaseAudioRecorderResources(call,result)
      "download" -> download(call,result)
      "pauseRecordingAudio" -> pauseRecordingAudio(call,result)
      "checkCameraPermission" -> checkCameraPermission(call, result)
      else -> result.notImplemented()
    }
  }


  private fun clearCache(context: Context): Boolean {
    try {
      val cacheDir = File(context.cacheDir.toString() + "/file_picker/")
      val files = cacheDir.listFiles()
      if (files != null) {
        for (file in files) {
          file.delete()
        }
      }
    } catch (ex: Exception) {
      Log.e("FileUtil", "There was an error while clearing cached files: $ex")
      return false
    }
    return true
  }


  private fun pickFile(call: MethodCall, result: Result) {

    val arguments = call.arguments as HashMap<*, *>
    var allowedExtensions: Array<String>? = null


    isMultipleSelection = arguments["allowMultipleSelection"] as Boolean
    withData = arguments["withData"] as Boolean
    fileType = resolveType(arguments["type"] as String);
    allowedExtensions = CometChatFileUtils.getMimeTypes(arguments["allowedExtensions"] as ArrayList<String>?)

    delegate!!.startFileExplorer(fileType, isMultipleSelection, withData, allowedExtensions , result)


  }


  private fun resolveType(type: String): String? {
    return when (type) {
      "audio" -> "audio/*"
      "image" -> "image/*"
      "video" -> "video/*"
      "media" -> "image/*,video/*"
      "file" -> "application/*"
      "any", "custom" -> "*/*"
      "dir" -> "dir"
      else -> null
    }
  }


  private fun setup(
          activity: Activity,
          activityBinding: ActivityPluginBinding) {
    this.activity = activity
    delegate = CometChatFilePickerDelegate(activity)
      // V2 embedding setup for activity listeners.
      activityBinding.addActivityResultListener(delegate!!)
      activityBinding.addRequestPermissionsResultListener(delegate!!)
  }




  private fun openFile(call: MethodCall, result: Result){
    OpenFile.openFile(call,result,context,activity)
  }



  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    channel = MethodChannel(flutterPluginBinding?.binaryMessenger!!, "cometchat_uikit_shared")
    activity = binding.activity
    channel.setMethodCallHandler(this)
    binding.addRequestPermissionsResultListener(this)

    activityBinding = binding
    setup(
            activity,
            activityBinding!!

    )







  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }

//  private fun playDefaultSound(call: MethodCall, result: Result) {
//    AudioPlayer().playDefaultSound(call,result,context)
//  }


  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  private fun playCustomSound(call: MethodCall, result: Result) {

    val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    vibrator= if (Build.VERSION.SDK_INT >= 31) {
      @SuppressLint("WrongConstant")
      val vibratorManager =
              context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
      vibratorManager.defaultVibrator

    } else {
      @Suppress("DEPRECATION")
      context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }

    if ((audioManager.ringerMode!=AudioManager.RINGER_MODE_SILENT && audioManager.isMusicActive) || audioManager.ringerMode==AudioManager.RINGER_MODE_VIBRATE) {
      if (Build.VERSION.SDK_INT >= 26) {
        vibrator?.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE))
      } else {
        vibrator?.vibrate(500)
      }

//      vibrator?.vibrate(com.cometchatworkspace.components.shared.primaryComponents.soundManager.CometChatSoundManager.VIBRATE_PATTERN, 2)
    }else if (audioManager.ringerMode==AudioManager.RINGER_MODE_NORMAL) {
      AudioPlayer().playCustomSound(call,result,context)
    }


  }

  //  private fun playURL(call: MethodCall, result: Result) {
//    AudioPlayer().playURL(call,result,context)
//  }
//
  private fun stopPlayer(result: Result) {
    AudioPlayer().stopPlayer(result)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


  fun getAudioManager(context: Context): AudioManager? {
    return context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
  }

  private fun hasPermissions(context: Context?, vararg permissions: String): Boolean {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && context != null) {
      for (permission in permissions) {
        if (ActivityCompat.checkSelfPermission(context, permission) !=
                PackageManager.PERMISSION_GRANTED) {

          return false
        }
      }
    }
    return true
  }
  

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {

    when (requestCode) {
      10 -> {
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

          if(hasPermissions(context, Manifest.permission.ACCESS_FINE_LOCATION,
                          Manifest.permission.ACCESS_COARSE_LOCATION)){
            successCallback!!.success( mapOf("status" to true,"message" to "location permission granted"))
          }
          else {
            successCallback!!.success( mapOf("status" to false,"message" to "location permission denied"))
          }
        } else {
          successCallback!!.success( mapOf("status" to false,"message" to "permission denied"))
        }
      }
      //        // this method is called when user will
//        // grant the permission for audio recording.

            101 -> if (grantResults.isNotEmpty()) {
                val permissionToRecord = grantResults[0] == PackageManager.PERMISSION_GRANTED

              if (permissionToRecord) {
                    AudioRecorderEventHandler.audioRecorder?.startRecording()
                if(audioRecordResult!=null){
                  audioRecordResult?.success(permissionToRecord)
                }
                    Toast.makeText(context, "Permissions Granted for record audio", Toast.LENGTH_LONG).show()
                } else {
                audioRecordResult?.success(false)
                audioRecordResult = null
                    Toast.makeText(context, "Permissions Denied for record audio", Toast.LENGTH_LONG).show()
                }
            }

      201 -> {
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (!granted) {
          Toast.makeText(activity, "Permissions Denied for camera", Toast.LENGTH_LONG).show()
        }
        cameraPermissionResult?.success(granted)
        cameraPermissionResult = null
      }

    }
    successCallback = null
    return true
  }


  private fun shareMessage(call: MethodCall, result: Result) {
    val arguments = call.arguments as HashMap<String, String>
    val message = arguments["message"];
    val type = arguments["type"];
    val mediaName = arguments["mediaName"]; // get File name
    val fileUrl = arguments["fileUrl"]; // get File url
    val mimeType = arguments["mimeType"]; // get Mime Type
    val subType = arguments["subtype"]; // get Mime Type
    val shareIntent = Intent()
    shareIntent.action = Intent.ACTION_SEND
    if (type == "text") {
      shareIntent.putExtra(Intent.EXTRA_TITLE, "")
      shareIntent.putExtra(Intent.EXTRA_TEXT, (message))
      shareIntent.type = "text/plain"
      val intent = Intent.createChooser(shareIntent, "Share message")
      intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
      context.startActivity(intent)
    } else if (type == "media") {
      if(subType == "image") {
        Glide.with(context).asBitmap()
          .load(Uri.parse(fileUrl))
          .into(object : SimpleTarget<Bitmap?>() {
            override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap?>?) {
              var path = MediaStore.Images.Media.insertImage(
                context.contentResolver,
                resource,
                mediaName,
                "Media"
              )
              shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(path))
              shareIntent.type = mimeType
              val intent = Intent.createChooser(shareIntent, "Share message")
              intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
              context.startActivity(intent)
            }
          })
      }else {
        downloadFileInNewThread(context, fileUrl, mediaName, mimeType, "share")
      }
    }
  }

  private fun downloadFileInNewThread(
    context: Context,
    fileUrl: String?,
    fileName: String?,
    mimeType: String?,
    action: String?
  ) {
    val file =
      File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), fileName)

    val downloadThread = Thread(Runnable {
      try {
        if (!file.exists()) {
          val url = URL(fileUrl)
          val connection =
            url.openConnection() as HttpURLConnection
          connection.connect()
          if (connection.responseCode != HttpURLConnection.HTTP_OK) {
            handleDownloadFailure(context)
            return@Runnable
          }
          val fileLength = connection.contentLength
          val input = connection.inputStream
          val output = FileOutputStream(file)
          val buffer = ByteArray(4096)
          var bytesRead: Int
          var totalBytesRead = 0
          while (input.read(buffer).also { bytesRead = it } != -1) {
            output.write(buffer, 0, bytesRead)
            totalBytesRead += bytesRead
          }
          output.flush()
          output.close()
          input.close()
          if (fileUrl != null && mimeType != null && action != null){
            handleDownloadSuccess(context, fileUrl, mimeType, action, file)
          }
        } else {
          if (fileUrl != null && mimeType != null && action != null) {
            handleDownloadSuccess(context, fileUrl, mimeType, action, file)
          }
        }
      } catch (e: java.lang.Exception) {
        Log.e("DownloadThread", "Error downloading file: " + e.message)
        handleDownloadFailure(context)
      }
    })
    downloadThread.start()
  }

  private fun handleDownloadSuccess(
    context: Context,
    fileUrl: String,
    mimeType: String,
    action: String,
    file: File
  ) {
    try {
      val shareIntent = Intent()
      shareIntent.action = Intent.ACTION_SEND
      shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(file.path))
      shareIntent.type = mimeType
      val intent = Intent.createChooser(shareIntent, "Share message")
      intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
      context.startActivity(intent)
    } catch (e: java.lang.Exception) {
      Toast.makeText(
        context,
        "Error" + ":" + e.message,
        Toast.LENGTH_LONG
      ).show()
    }
  }

  private fun handleDownloadFailure(context: Context) {
    (activity).runOnUiThread {
      // File download failed
      // Handle the failure scenario
      Toast.makeText(
        context,
        "Download Failed",
        Toast.LENGTH_SHORT
      ).show()
    }
  }

  /// [download] to download files.
  private fun download(call: MethodCall, result: Result) {
    val arguments = call.arguments as HashMap<String, String>
    val fileUrl = arguments["fileUrl"];

    val fileName = fileUrl!!.substring(fileUrl.lastIndexOf('/') + 1)
    val file = File(
            context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS),
            "Recording - $fileName"
    )

    // need to create the file if it does not exist.
    if (!file.exists()) {
      file.createNewFile()
    }

    val downloadThread = Thread(Runnable {
      try {
        val url = URL(fileUrl)
        val connection = url.openConnection() as HttpURLConnection
        connection.connect()

        if (connection.responseCode != HttpURLConnection.HTTP_OK) {
          handleDownloadFailure(context, "Server returned HTTP response code: ${connection.responseCode}")
          return@Runnable
        }

        val input = connection.inputStream
        val output = FileOutputStream(file)
        val buffer = ByteArray(4096)
        var bytesRead: Int

        while (input.read(buffer).also { bytesRead = it } != -1) {
          output.write(buffer, 0, bytesRead)
        }

        output.flush()
        output.close()
        input.close()

        // Show success toast on UI thread
        showToastOnMainThread(context, "Download Success")

      } catch (e: Exception) {
        Log.e("DownloadThread", "Error downloading file: ${e.message}")
        // Show error toast on UI thread
        handleDownloadFailure(context, "Download Failed: ${e.message}")
      }
    })
    downloadThread.start()
  }

  /// [showToastOnMainThread] Method to show a Toast message on the UI thread
  private fun showToastOnMainThread(context: Context, message: String) {
    Handler(Looper.getMainLooper()).post {
      Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
    }
  }

  /// [handleDownloadFailure] Method to handle download failure and show a Toast message
  private fun handleDownloadFailure(context: Context, message: String) {
    showToastOnMainThread(context, message)
  }

  private var audioRecordResult: Result? = null

  ///[startRecordingAudio] is used to start the recording audio
  private fun startRecordingAudio(call: MethodCall, result: Result){
    AudioRecorderEventHandler.audioRecorder = AudioRecorder(context,activity)
    val isRecording = AudioRecorderEventHandler.audioRecorder?.startRecording()
    result.success(isRecording)
  }

  ///[stopRecordingAudio] is used to stop the recording audio
  private fun stopRecordingAudio(call: MethodCall, result: Result){
    if (AudioRecorderEventHandler.audioRecorder != null ){
      val filePath : String? = AudioRecorderEventHandler.audioRecorder?.pauseRecording()
//      AudioRecorderEventHandler.audioRecorder = null
      AudioRecorderEventHandler.onCancel(null)
      result.success(filePath)
    }

  }

  ///[playRecordedAudio] is used to play the recorded audio
  private fun playRecordedAudio(call: MethodCall, result: Result){
    if (AudioRecorderEventHandler.audioRecorder != null ){
      AudioRecorderEventHandler.audioRecorder?.playAudio()
    }
  }

  ///[pausePlayingRecordedAudio] is used to pause the playing recorded audio
  private fun pausePlayingRecordedAudio(call: MethodCall, result: Result){
    if (AudioRecorderEventHandler.audioRecorder != null ){
      AudioRecorderEventHandler.audioRecorder?.pausePlaying()
    }
  }

  ///[deleteFile] is used to delete the file from the device
  private fun deleteFile(call: MethodCall, result: Result) {
    var filePath: String? = null
    if (call.hasArgument("filePath")) {
      filePath = call.argument<String>("filePath")
    }
    if (filePath == null) {
      result.error("Invalid Arguments", "filePath cannot be null", null)
    } else {
      try {
        val file = File(filePath)
        val isDeleted : Boolean = file.delete()
        result.success(isDeleted)
      } catch (e: Exception) {
        result.success(false)
      }
    }
  }

  ///[releaseAudioRecorderResources] is used to release the resources of the audio recorder
  private fun releaseAudioRecorderResources(call: MethodCall, result: Result) {
    if (AudioRecorderEventHandler.audioRecorder != null ){
      AudioRecorderEventHandler.audioRecorder?.releaseMediaResources()
      AudioRecorderEventHandler.audioRecorder=null
      AudioRecorderEventHandler.onCancel(null)
    }
  }

  ///[pauseRecordingAudio] is used to pause the recording of the audio
  private fun pauseRecordingAudio(call: MethodCall, result: Result) {
    if (AudioRecorderEventHandler.audioRecorder != null) {
      AudioRecorderEventHandler.audioRecorder?.pauseRecording()
    }
  }

  private var cameraPermissionResult: Result? = null

  private fun checkCameraPermission(call: MethodCall, result: Result) {
    val permission = Manifest.permission.CAMERA

    if (ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED) {
      result.success(true)
    } else {
      val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)

      if (shouldShowRationale) {
        // Ask permission again
        cameraPermissionResult = result
        ActivityCompat.requestPermissions(activity, arrayOf(permission), 201)
      } else {
        // Show toast on main thread
        Handler(Looper.getMainLooper()).post {
          Toast.makeText(activity, "Camera permission is required to take photos", Toast.LENGTH_LONG).show()
        }
        result.success(false)
      }
    }
  }
}

