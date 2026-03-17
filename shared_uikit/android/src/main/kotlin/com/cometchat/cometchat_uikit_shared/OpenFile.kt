package com.cometchat.cometchat_uikit_shared

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class FileProvider : FileProvider()

class OpenFile {

    companion object {
        fun openFile(call: MethodCall, result: MethodChannel.Result, context: Context, activity: Activity) {
            val filePath: String = call.argument("file_path") ?: ""
            var fileType: String = call.argument("file_type") ?: ""
            val fileUrl: String = call.argument("file_url") ?: ""

            if (filePath.lowercase().endsWith(".heic") || filePath.lowercase().endsWith(".heif")) {
                fileType = "image/*"
            }

            if (fileType.isEmpty()) {
                fileType = getMimeType(filePath)
            }

            try {
                val file = File(filePath)
                if (!file.exists()) {
                    result.success("File not found")
                    return
                }

                val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val authority = "${context.packageName}.fileProvider.com.cometchat.cometchat_uikit_shared"
                    FileProvider.getUriForFile(context, authority, file)
                } else {
                    Uri.fromFile(file)
                }

                val viewIntent = Intent(Intent.ACTION_VIEW)
                viewIntent.setDataAndType(uri, fileType)
                viewIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                val chooser = Intent.createChooser(viewIntent, "Open with")
                chooser.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                try {
                    activity.startActivity(chooser)
                    result.success("Success")
                } catch (e: ActivityNotFoundException) {
                    // No native app — fall back to Google Docs Viewer in browser
                    openInBrowser(fileUrl, activity, result)
                }
            } catch (e: Exception) {
                // Any other failure — try browser fallback
                openInBrowser(fileUrl, activity, result)
            }
        }

        private fun openInBrowser(fileUrl: String, activity: Activity, result: MethodChannel.Result) {
            if (fileUrl.isNotEmpty()) {
                val encoded = Uri.encode(fileUrl, ":/?#[]@!\$&'()*+,;=-._~")
                val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://docs.google.com/gview?embedded=true&url=$encoded"))
                activity.startActivity(browserIntent)
                result.success("Success")
            } else {
                result.success("No app found to open this file")
            }
        }

        private fun getMimeType(filePath: String): String {
            val ext = filePath.substringAfterLast('.', "").lowercase()
            return when (ext) {
                "pdf" -> "application/pdf"
                "doc" -> "application/msword"
                "docx" -> "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                "xls" -> "application/vnd.ms-excel"
                "xlsx" -> "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                "ppt" -> "application/vnd.ms-powerpoint"
                "pptx" -> "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                "txt" -> "text/plain"
                "csv" -> "text/csv"
                "zip" -> "application/zip"
                "jpg", "jpeg" -> "image/jpeg"
                "png" -> "image/png"
                "gif" -> "image/gif"
                "mp3" -> "audio/mpeg"
                "mp4" -> "video/mp4"
                "mov" -> "video/quicktime"
                else -> "application/octet-stream"
            }
        }
    }
}
