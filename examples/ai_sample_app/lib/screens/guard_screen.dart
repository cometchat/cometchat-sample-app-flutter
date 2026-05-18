import 'package:flutter/material.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_chat_uikit/cometchat_calls_uikit.dart';
import 'login_screen.dart';
import 'ai_agents_screen.dart';

class GuardScreen extends StatefulWidget {
  const GuardScreen({super.key});
  @override
  State<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  final ValueNotifier<bool?> _shouldGoHome = ValueNotifier<bool?>(null);
  late CometChatColorPalette _colorPalette;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorPalette = CometChatThemeHelper.getColorPalette(context);
    if (_initialized) return;
    _initialized = true;
    _checkSession();
  }

  Future<void> _checkSession() async {
    final cachedUser = await CometChatUIKit.getLoggedInUser();
    if (cachedUser != null) {
      await CometChatUIKit.login(
        cachedUser.uid,
        onSuccess: (_) async {
          await CallEventService.instance.init(configuration: CallingConfiguration());
          _shouldGoHome.value = true;
        },
        onError: (e) => _shouldGoHome.value = false,
      );
    } else {
      _shouldGoHome.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _shouldGoHome,
      builder: (context, value, _) {
        if (value == null) {
          return Material(
            color: _colorPalette.background1,
            child: Center(child: CircularProgressIndicator(color: _colorPalette.primary)),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => value ? const AiAgentsScreen() : const LoginScreen()),
            (route) => false);
        });
        return const SizedBox();
      },
    );
  }
}
