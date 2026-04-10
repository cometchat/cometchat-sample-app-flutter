import 'package:flutter/material.dart';

import '../app_credentials.dart';
import '../main.dart';

/// Screen where users enter their CometChat App ID, Region, and Auth Key.
///
/// Shown on first launch when [AppCredentials] has no hardcoded or saved
/// credentials. Uses the app's Material theme so it follows system
/// light/dark mode automatically.
class AppCredentialsScreen extends StatefulWidget {
  const AppCredentialsScreen({super.key});

  @override
  State<AppCredentialsScreen> createState() => _AppCredentialsScreenState();
}

class _AppCredentialsScreenState extends State<AppCredentialsScreen> {
  String? _selectedRegion;
  final _appIdController = TextEditingController();
  final _authKeyController = TextEditingController();
  bool _isLoading = false;

  static const _regions = [
    ('us', '🇺🇸 US'),
    ('eu', '🇪🇺 EU'),
    ('in', '🇮🇳 IN'),
  ];

  @override
  void dispose() {
    _appIdController.dispose();
    _authKeyController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (_selectedRegion == null) {
      _showError('Please select a region');
      return;
    }
    final appId = _appIdController.text.trim();
    if (appId.isEmpty) {
      _showError('Please enter App ID');
      return;
    }
    final authKey = _authKeyController.text.trim();
    if (authKey.isEmpty) {
      _showError('Please enter Auth Key');
      return;
    }

    setState(() => _isLoading = true);
    await AppCredentials.saveCredentials(appId, _selectedRegion!, authKey);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SampleAppHome()),
      (_) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Image.asset(
                        'assets/cometchat_logo_with_text.png',
                        color: colorScheme.onSurface,
                        height: 26,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'App Credentials',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCredentialsCard(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCredentialsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Region',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _regions.map((r) {
            final (code, label) = r;
            final isSelected = _selectedRegion == code;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: r != _regions.last ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRegion = code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(
          'App ID',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _appIdController,
          style: TextStyle(color: colorScheme.onSurface),
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Enter App ID',
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Auth Key',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _authKeyController,
          style: TextStyle(color: colorScheme.onSurface),
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Enter Auth Key',
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
