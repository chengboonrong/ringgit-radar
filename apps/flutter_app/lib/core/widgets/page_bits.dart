import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import 'ring.dart';

class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Semantics(header: true, child: Text(text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w400))),
      );
}

/// The outlined chip: the same shape as the Filter button (radius 8, 1.5 outline, 44 tall). It leads
/// somewhere when only [onTap] is given, and is a toggle when [selected] is set (red fill, white text).
class OutlineChip extends StatelessWidget {
  const OutlineChip({super.key, required this.label, required this.onTap, this.selected});

  final String label;
  final VoidCallback onTap;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final on = selected ?? false;
    return RingTarget(
      radius: 8,
      selected: selected,
      label: label,
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: on ? brandRed : Colors.transparent,
          border: Border.all(color: on ? brandRed : tk.hint, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ExcludeSemantics(
          child: Center(
            widthFactor: 1,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (on) ...[const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white), const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: on ? Colors.white : tk.text)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Section heading inside a page.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Semantics(header: true, child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
      );
}
