import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../server_store.dart';

/// Asks the user for the YouTrack server URL.
class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({
    super.key,
    required this.onSubmit,
    this.initialUrl,
    this.onCancel,
  });

  final ValueChanged<String> onSubmit;
  final String? initialUrl;

  /// Null on first launch, when there is no server to go back to.
  final VoidCallback? onCancel;

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  late final _controller = TextEditingController(text: widget.initialUrl);
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final url = ServerStore.normalize(_controller.text);
    if (url == null) {
      setState(() => _invalid = true);
      return;
    }
    widget.onSubmit(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.dns_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.serverTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.serverPrompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.serverUrlLabel,
                    hintText: 'https://example.youtrack.cloud',
                    errorText: _invalid ? l10n.invalidUrl : null,
                  ),
                  onChanged: (_) {
                    if (_invalid) setState(() => _invalid = false);
                  },
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _submit, child: Text(l10n.connect)),
                if (widget.onCancel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(l10n.cancel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
