import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// Says once that the app is independent and unofficial. Returns when the dialog closes by any means: OK,
/// a tap outside, back, or the data-sources link, which closes it and then calls [onDataSources].
Future<void> showFirstLaunchNotice(BuildContext navigatorContext, {required VoidCallback onDataSources}) async {
  var openData = false;
  await showDialog<void>(
    context: navigatorContext,
    builder: (context) {
      final l = context.l10n;
      return AlertDialog(
        title: Text(l.noticeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.noticeBody),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              onPressed: () {
                openData = true;
                Navigator.of(context).pop();
              },
              child: Text(l.dataSourcesTitle),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.noticeOk))],
      );
    },
  );
  if (openData) onDataSources();
}
