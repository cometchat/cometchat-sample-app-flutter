package com.cometchat.calls;

import com.cometchat.calls.model.RTCCallback;

/**
 * Stub class that satisfies the Chat SDK's native CallManager dependency check.
 *
 * The Chat SDK (chat-sdk-android 4.2.0) CallManager.deprecatedCallModuleExists()
 * uses Class.forName("com.cometchat.calls.CometChatRTCView") to detect if the
 * calling module is present. In V5 of the Calls SDK, CometChatRTCView was removed
 * (replaced by the Jitsi/WebRTC-based session system). Without this stub, the
 * CallManager skips all call lifecycle tracking (startCall jumps to exit),
 * causing outgoing call cancel to fail and incoming call accept to fail with
 * "The call is ended".
 *
 * All methods are no-ops — the actual call UI is handled by the V5 Calls SDK's
 * joinSession/leaveSession flow via Flutter platform views.
 */
public class CometChatRTCView {

    public void switchCameraSource() {
        // No-op: V5 handles camera via WebRTC
    }

    public void muteAudio() {
        // No-op: V5 handles audio via WebRTC
    }

    public void unMuteAudio() {
        // No-op
    }

    public void pauseVideo() {
        // No-op: V5 handles video via WebRTC
    }

    public void unPauseVideo() {
        // No-op
    }

    public void setAudioMode(String mode) {
        // No-op
    }

    public void getAudioModes(RTCCallback callback) {
        // No-op
    }

    public void endCallSession() {
        // No-op: V5 uses CallSession.leaveSession()
    }

    public void enterPIPMode() {
        // No-op
    }

    public void exitPIPMode() {
        // No-op
    }

    public void switchToVideoCall() {
        // No-op
    }

    public void startRecording() {
        // No-op
    }

    public void stopRecording() {
        // No-op
    }
}
