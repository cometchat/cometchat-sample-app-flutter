package com.hiennv.flutter_callkit_incoming

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.fasterxml.jackson.core.type.TypeReference


private const val CALLKIT_PREFERENCES_FILE_NAME = "flutter_callkit_incoming"
private var prefs: SharedPreferences? = null
private var editor: SharedPreferences.Editor? = null

private fun initInstance(context: Context) {
    prefs = context.getSharedPreferences(CALLKIT_PREFERENCES_FILE_NAME, Context.MODE_PRIVATE)
    editor = prefs?.edit()
}


fun addCall(context: Context?, data: Data, isAccepted: Boolean = false) {
    val json = getString(context, "ACTIVE_CALLS", "[]")
    val arrayData: ArrayList<Data> = Utils.getGsonInstance()
        .readValue(json, object : TypeReference<ArrayList<Data>>() {})
    val currentData = arrayData.find { it == data }
    if(currentData != null) {
        currentData.isAccepted = isAccepted
    }else {
        arrayData.add(data)
    }
    putString(context, "ACTIVE_CALLS", Utils.getGsonInstance().writeValueAsString(arrayData))
}

fun removeCall(context: Context?, data: Data) {
    val json = getString(context, "ACTIVE_CALLS", "[]")
    Log.d("JSON", json!!)
    val arrayData: ArrayList<Data> = Utils.getGsonInstance()
        .readValue(json, object : TypeReference<ArrayList<Data>>() {})
    arrayData.remove(data)
    putString(context, "ACTIVE_CALLS", Utils.getGsonInstance().writeValueAsString(arrayData))
}

fun removeAllCalls(context: Context?) {
    putString(context, "ACTIVE_CALLS", "[]")
    remove(context, "ACTIVE_CALLS")
}

fun getDataActiveCalls(context: Context?): ArrayList<Data> {
    val json = getString(context, "ACTIVE_CALLS", "[]")
    return Utils.getGsonInstance()
        .readValue(json, object : TypeReference<ArrayList<Data>>() {})
}

fun getDataActiveCallsForFlutter(context: Context?): ArrayList<Map<String, Any?>> {
    val json = getString(context, "ACTIVE_CALLS", "[]")
    return Utils.getGsonInstance().readValue(json, object : TypeReference<ArrayList<Map<String, Any?>>>() {})
}

fun putString(context: Context?, key: String, value: String?) {
    if (context == null) return
    initInstance(context)
    editor?.putString(key, value)
    editor?.commit()
}

fun getString(context: Context?, key: String, defaultValue: String = ""): String? {
    if (context == null) return null
    initInstance(context)
    return prefs?.getString(key, defaultValue)
}

fun remove(context: Context?, key: String) {
    if (context == null) return
    initInstance(context)
    editor?.remove(key)
    editor?.commit()
}
