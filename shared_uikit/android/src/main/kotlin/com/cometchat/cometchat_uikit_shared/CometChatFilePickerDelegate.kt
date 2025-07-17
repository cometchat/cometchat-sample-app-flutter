package com.cometchat.cometchat_uikit_shared

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Parcelable
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import java.io.File
import java.util.ArrayList
import java.util.HashMap
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class CometChatFilePickerDelegate (constActivity: Activity): PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {

    private val TAG = "FilePickerDelegate"
    private val REQUEST_CODE = CometchatUikitSharedPlugin::class.java.hashCode() + 43 and 0x0000ffff

    private var activity: Activity = constActivity
    private var pendingResult: MethodChannel.Result? = null
    private var isMultipleSelection = false
    private var type: String? = null
    private var loadDataToMemory = false
    private var allowedExtensions: Array<String>? = null


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (type == null) {
            return false
        }

        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            this.dispatchEventStatus(true)
            Thread(Runnable {
                if (data != null) {
                    val files = ArrayList<CometChatFileInfo>()
                    if (data.clipData != null) {
                        val count = data.clipData!!.itemCount
                        var currentItem = 0
                        while (currentItem < count) {
                            val currentUri = data.clipData!!.getItemAt(currentItem).uri
                            val file = CometChatFileUtils.openFileStream(this.activity!!, currentUri, loadDataToMemory)
                            if (file != null) {
                                files.add(file)
                            }
                            currentItem++
                        }
                        finishWithSuccess(files)
                    } else if (data.data != null) {
                        var uri = data.data
                        if (type == "dir" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            uri = DocumentsContract.buildDocumentUriUsingTree(uri, DocumentsContract.getTreeDocumentId(uri))
                            val dirPath = CometChatFileUtils.getFullPathFromTreeUri(uri, this.activity!!)
                            dirPath?.let { finishWithSuccess(it) }
                                ?: finishWithError("unknown_path", "Failed to retrieve directory path.")
                            return@Runnable
                        }
                        val file = CometChatFileUtils.openFileStream(this.activity!!, uri!!, loadDataToMemory)
                        if (file != null) {
                            files.add(file)
                        }
                        if (!files.isEmpty()) {
                            finishWithSuccess(files)
                        } else {
                            finishWithError("unknown_path", "Failed to retrieve path.")
                        }
                    } else if (data.extras != null) {
                        val bundle = data.extras
                        if (bundle!!.keySet().contains("selectedItems")) {
                            val fileUris = bundle.getParcelableArrayList<Parcelable>("selectedItems")
                            var currentItem = 0
                            if (fileUris != null) {
                                for (fileUri in fileUris) {
                                    if (fileUri is Uri) {
                                        val currentUri = fileUri
                                        val file = CometChatFileUtils.openFileStream(this.activity!!, currentUri, loadDataToMemory)
                                        if (file != null) {
                                            files.add(file)
                                        }
                                    }
                                    currentItem++
                                }
                            }
                            finishWithSuccess(files)
                        } else {
                            finishWithError("unknown_path", "Failed to retrieve path from bundle.")
                        }
                    } else {
                        finishWithError("unknown_activity", "Unknown activity error, please fill an issue.")
                    }
                } else {
                    finishWithError("unknown_activity", "Unknown activity error, please fill an issue.")
                }
            }).start()
            return true
        } else if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_CANCELED) {
            finishWithSuccess(null)
            return true
        } else if (requestCode == REQUEST_CODE) {
            finishWithError("unknown_activity", "Unknown activity error, please fill an issue.")
        }
        return false
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (REQUEST_CODE != requestCode) {
            return false
        }

        val permissionGranted = grantResults!!.size > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED

        if (permissionGranted) {
            this.launchFileExplorer()
        } else {
            finishWithError("read_external_storage_denied", "User did not allow reading external storage")
        }

        return true
    }

    private fun launchFileExplorer() {

        if (type == null) {
            return
        }

        val intent: Intent = when {
            type == "dir" -> {
                Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
            }
            type?.startsWith("image") == true -> {
                Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    this.type = "image/*"
                    putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection)
                }
            }

            type?.startsWith("video") == true -> {
                Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    this.type = "video/*"
                    putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection)
                }
            }
            type?.startsWith("audio") == true -> {
                createAudioPickerIntent()
            }
            else -> {
                Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    this.type = type ?: "*/*"
                    putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection)
                    allowedExtensions?.let {
                        putExtra(Intent.EXTRA_MIME_TYPES, it)
                    }
                }
            }
        }

        try {
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (e: Exception) {
            finishWithError("activity_not_found", "No app found to pick the file.")
        }
    }

    private fun createAudioPickerIntent(): Intent {
        // Prioritize ACTION_PICK with MediaStore for reliability, which is what you were using.
        val pickIntent = Intent(Intent.ACTION_PICK, MediaStore.Audio.Media.EXTERNAL_CONTENT_URI)

        // Check if any app on the device can handle the primary intent.
        if (activity.packageManager.resolveActivity(pickIntent, PackageManager.MATCH_DEFAULT_ONLY) != null) {
            return pickIntent.apply {
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection)
            }
        }

        // If not, fall back to the more general ACTION_GET_CONTENT.
        // This is more likely to be supported as it allows apps like file managers to respond.
        return Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            this.type = "audio/*"
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection)
        }
    }


    private fun finishWithSuccess(data: Any?) {
        var data: Any? = data
        this.dispatchEventStatus(false)

        if (pendingResult != null) {
            if (data != null && data !is String) {
                val files = ArrayList<HashMap<String, Any?>>()
                for (file in data as ArrayList<CometChatFileInfo>) {
                    files.add(file.toMap())
                }
                data = files
            }
            pendingResult!!.success(data)
            this.clearPendingResult()
            this.resetState()
        }
    }

    private fun finishWithError(errorCode: String, errorMessage: String) {
        if (pendingResult == null) {
            return
        }
        dispatchEventStatus(false)
        pendingResult!!.error(errorCode, errorMessage, null)
        clearPendingResult()
    }

    private fun dispatchEventStatus(status: Boolean) {
        // Implementation remains the same
    }

    private fun clearPendingResult() {
        pendingResult = null
    }

    fun startFileExplorer(
        type: String?,
        isMultipleSelection: Boolean,
        withData: Boolean,
        allowedExtensions: Array<String>?,
        result: MethodChannel.Result?
    ) {
        if (!this.setPendingMethodCallAndResult(result!!)) {
            finishWithAlreadyActiveError(result)
            return
        }

        this.type = type
        this.isMultipleSelection = isMultipleSelection
        loadDataToMemory = withData
        this.allowedExtensions = allowedExtensions

        if ((type?.startsWith("image") == true || type?.startsWith("video") == true) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            startPhotoPicker()
        } else {
            this.launchFileExplorer()
        }
    }

    private fun startPhotoPicker() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val intent = when {
                type?.startsWith("image") == true -> {
                    Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                        putExtra(MediaStore.EXTRA_PICK_IMAGES_MAX, if (isMultipleSelection) 5 else 1)
                    }
                }
                type?.startsWith("video") == true -> {
                    Intent(Intent.ACTION_PICK, MediaStore.Video.Media.EXTERNAL_CONTENT_URI).apply {
                        type = "video/*"
                        putExtra(Intent.EXTRA_ALLOW_MULTIPLE, isMultipleSelection)
                    }
                }
                else -> {
                    launchFileExplorer()
                    return
                }
            }
            activity.startActivityForResult(intent, REQUEST_CODE)
        } else {
            launchFileExplorer()
        }
    }

    private fun setPendingMethodCallAndResult(result: MethodChannel.Result): Boolean {
        if (pendingResult != null) {
            return false
        }
        pendingResult = result
        return true
    }

    private fun finishWithAlreadyActiveError(result: MethodChannel.Result) {
        result.error("already_active", "File picker is already active", null)
    }

    private fun resetState() {
        type = null
        isMultipleSelection = false
        allowedExtensions = null
        loadDataToMemory = false
    }
}