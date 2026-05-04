import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';

/// CometChat App Credentials for the AI Sample App.
///
/// On first launch, the app shows [AppCredentialsScreen] so the user can
/// enter their own CometChat App ID, Auth Key, and Region. The values are
/// persisted via SharedPreferences and loaded on subsequent launches.
class AppCredentials {
  static String appId = '26580020f03ff346';
  static String authKey = '4152b0366478871f0fa8d19a287dd6f5ed5f8eff';
  static String region = 'in';

  static bool get hasValidCredentials =>
      appId.isNotEmpty && authKey.isNotEmpty && region.isNotEmpty;

  static Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    appId = prefs.getString('cometchat_app_id') ?? appId;
    authKey = prefs.getString('cometchat_auth_key') ?? authKey;
    region = prefs.getString('cometchat_region') ?? region;
  }

  static Future<void> saveCredentials({
    required String appId,
    required String authKey,
    required String region,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cometchat_app_id', appId);
    await prefs.setString('cometchat_auth_key', authKey);
    await prefs.setString('cometchat_region', region);
    AppCredentials.appId = appId;
    AppCredentials.authKey = authKey;
    AppCredentials.region = region;
  }
}

/// Screen shown on first launch to collect CometChat credentials.
class AppCredentialsScreen extends StatefulWidget {
  const AppCredentialsScreen({super.key});

  @override
  State<AppCredentialsScreen> createState() => _AppCredentialsScreenState();
}

class _AppCredentialsScreenState extends State<AppCredentialsScreen> {
  final _appIdController = TextEditingController();
  final _authKeyController = TextEditingController();
  final _regionController = TextEditingController(text: 'us');
  bool _isSaving = false;

  @override
  void dispose() {
    _appIdController.dispose();
    _authKeyController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final appId = _appIdController.text.trim();
    final authKey = _authKeyController.text.trim();
    final region = _regionController.text.trim();

    if (appId.isEmpty || authKey.isEmpty || region.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await AppCredentials.saveCredentials(
      appId: appId,
      authKey: authKey,
      region: region,
    );

    if (mounted) {
      // Initialize CometChat with the new credentials, then navigate
      final settingsBuilder = UIKitSettingsBuilder()
        ..subscriptionType = CometChatSubscriptionType.allUsers
        ..region = region
        ..autoEstablishSocketConnection = true
        ..appId = appId
        ..authKey = authKey;

      final uiKitSettings = settingsBuilder.build();

      CometChatUIKit.init(
        uiKitSettings: uiKitSettings,
        onSuccess: (_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const _CredentialsSavedRedirect(),
              ),
            );
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Init failed: ${e.message}')),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CometChat Credentials')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your CometChat credentials to get started.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authKeyController,
              decoration: const InputDecoration(
                labelText: 'Auth Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _regionController,
              decoration: const InputDecoration(
                labelText: 'Region (us or eu)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save & Initialize'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple redirect that restarts the app flow after credentials are saved.
class _CredentialsSavedRedirect extends StatelessWidget {
  const _CredentialsSavedRedirect();

  @override
  Widget build(BuildContext context) {
    // Restart the app by replacing with the main widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const _RestartApp(),
        ),
        (route) => false,
      );
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _RestartApp extends StatelessWidget {
  const _RestartApp();

  @override
  Widget build(BuildContext context) {
    // Re-import and rebuild the main app
    return MaterialApp(
      home: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const _PlaceholderRestart(),
              ),
              (route) => false,
            );
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}

class _PlaceholderRestart extends StatelessWidget {
  const _PlaceholderRestart();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text('Credentials saved! Please restart the app.'),
          ],
        ),
      ),
    );
  }
}
