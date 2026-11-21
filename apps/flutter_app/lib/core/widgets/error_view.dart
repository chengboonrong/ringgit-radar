import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../api/api_client.dart';
import 'ring.dart';

/// An error in the reader's language: what failed, then why.
String errorText(AppLocalizations l, Object error) {
  if (error is! ApiException) return l.somethingWentWrong;
  final why = switch (error.failure) {
    ApiFailure.status => l.serverAnswered(error.status ?? 0),
    ApiFailure.unreachable => l.serverUnreachable,
    ApiFailure.badShape => l.unexpectedAnswer,
  };
  return '${l.couldNotLoad(error.what.name)} $why';
}

/// Says what failed and offers Retry.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.wifiSlash, size: 36, color: tk.hint),
            const SizedBox(height: 12),
            Text(errorText(context.l10n, error), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            RedButton(label: context.l10n.retry, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

/// The red button. Always at least 44 tall.
class RedButton extends StatelessWidget {
  const RedButton({super.key, required this.label, required this.onTap, this.outlined = false, this.icon, this.minWidth = 120, this.expand = false, this.semanticsLabel});

  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;
  final double minWidth;
  final bool expand;
  /// What a screen reader says when the visible label is too short to say it alone. Defaults to [label].
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final fg = outlined ? tk.text : Colors.white;
    return RingTarget(
      onTap: onTap,
      radius: 10,
      label: semanticsLabel ?? label,
      child: Container(
        width: expand ? double.infinity : null,
        constraints: BoxConstraints(minHeight: 48, minWidth: minWidth),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : brandRed,
          border: outlined ? Border.all(color: tk.hint, width: 1.5) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: fg))),
            ],
          ),
        ),
      ),
    );
  }
}
