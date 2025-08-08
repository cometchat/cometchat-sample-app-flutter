import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_callkit_incoming');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(channel, (methodCall) async => '42');
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });
}
