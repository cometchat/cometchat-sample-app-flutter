// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

void main() {
  const oldS = CometChatVoiceNoteBubbleStyle(playIconColor: Color(0xFF0000FF));
  const newS = CometChatVoiceNoteBubbleStyle(playIconColor: Color(0xFF00FF00));

  test('legacy audioBubbleStyle alone still applies (back-compat)', () {
    final c = AdditionalConfigurations(audioBubbleStyle: oldS);
    expect(c.effectiveVoiceNoteBubbleStyle, oldS);
  });

  test('voiceNoteBubbleStyle wins when both are set', () {
    final c = AdditionalConfigurations(
      audioBubbleStyle: oldS,
      voiceNoteBubbleStyle: newS,
    );
    expect(c.effectiveVoiceNoteBubbleStyle, newS);
  });

  test('incoming/outgoing: legacy param still applies, new one wins', () {
    const inOld = CometChatIncomingMessageBubbleStyle(audioBubbleStyle: oldS);
    expect(inOld.effectiveVoiceNoteBubbleStyle, oldS);
    const inBoth = CometChatIncomingMessageBubbleStyle(
      audioBubbleStyle: oldS,
      voiceNoteBubbleStyle: newS,
    );
    expect(inBoth.effectiveVoiceNoteBubbleStyle, newS);

    const outOld = CometChatOutgoingMessageBubbleStyle(audioBubbleStyle: oldS);
    expect(outOld.effectiveVoiceNoteBubbleStyle, oldS);
  });

  test('copyWith preserves both fields', () {
    const s = CometChatIncomingMessageBubbleStyle(
      audioBubbleStyle: oldS,
      voiceNoteBubbleStyle: newS,
    );
    final copy = s.copyWith();
    expect(
      copy.audioBubbleStyle,
      oldS,
      reason: 'legacy field survives copyWith',
    );
    expect(
      copy.voiceNoteBubbleStyle,
      newS,
      reason: 'new field survives copyWith',
    );
  });

  test('old style type name still usable via deprecated alias', () {
    const viaAlias = CometChatAudioBubbleStyle(
      playIconColor: Color(0xFF0000FF),
    );
    expect(viaAlias, isA<CometChatVoiceNoteBubbleStyle>());
  });
}
