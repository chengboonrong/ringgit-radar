import 'package:flutter/material.dart';

import '../lists/list_page.dart';
import '../lists/list_spec.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) => const ListPage(title: 'Sale', spec: ListSpec.sale, scope: 'sale');
}
