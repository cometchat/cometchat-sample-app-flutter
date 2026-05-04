package com.cometchat.calls.model;

/**
 * Stub interface for V4 compatibility.
 * The Chat SDK's CallManager references RTCCallback in CometChatRTCView.getAudioModes().
 * This class was removed in Calls SDK V5.
 */
public interface RTCCallback {
    void onSuccess(Object result);
    void onError(Object error);
}
