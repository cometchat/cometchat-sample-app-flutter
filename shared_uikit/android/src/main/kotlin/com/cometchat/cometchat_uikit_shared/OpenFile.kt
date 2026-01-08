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

class OpenFile{

    companion object {
        fun openFile(call: MethodCall, result: MethodChannel.Result, context: Context, activity: Activity) {
            val filePath: String = call.argument("file_path") ?: ""
            var fileType: String = call.argument("file_type") ?: ""

            // Handle HEIC files specifically
            if (filePath.lowercase().endsWith(".heic") || filePath.lowercase().endsWith(".heif")) {
                fileType = "image/*"
            }

            val intent = Intent(Intent.ACTION_VIEW)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            intent.addCategory(Intent.CATEGORY_DEFAULT)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

            try {
                val uri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val packageName: String = context.packageName
                    FileProvider.getUriForFile(
                        context,
                        "$packageName.fileProvider.com.cometchat.cometchat_uikit_shared",
                        File(filePath)
                    )
                } else {
                    Uri.fromFile(File(filePath))
                }

                intent.setDataAndType(uri, fileType)

                // Grant temporary read permission to all apps that might handle this intent
                val resInfoList = context.packageManager.queryIntentActivities(intent, 0)
                for (resolveInfo in resInfoList) {
                    val packageName = resolveInfo.activityInfo.packageName
                    context.grantUriPermission(
                        packageName,
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                }

                activity.startActivity(Intent.createChooser(intent, "Open with"))
                result.success("Success")
            } catch (e: ActivityNotFoundException) {
                result.success("No app found to open this file")
            } catch (e: Exception) {
                result.success("Error opening file: ${e.message}")
            }
        }
    }
}