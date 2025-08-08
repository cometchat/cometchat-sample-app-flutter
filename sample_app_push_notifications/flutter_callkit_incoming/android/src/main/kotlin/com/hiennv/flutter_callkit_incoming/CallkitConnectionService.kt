package com.hiennv.flutter_callkit_incoming

import android.os.Build
import android.telecom.ConnectionService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.M)
class CallkitConnectionService: ConnectionService() {
    //not need overridesss
}