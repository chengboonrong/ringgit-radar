import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/widgets/ring.dart';
import 'theme.dart';

class NavItem {
  const NavItem(this.path, this.label, this.icon, this.iconFilled);
  final String path;
  final String label;
  final IconData icon;
  final IconData iconFilled;
}

final _highlights = NavItem('/', 'Highlights', PhosphorIconsRegular.star, PhosphorIconsFill.star);
final _search = NavItem('/search', 'Search', PhosphorIconsRegular.magnifyingGlass, PhosphorIconsFill.magnifyingGlass);
final _wish = NavItem('/wish-list', 'Wish List', PhosphorIconsRegular.heart, PhosphorIconsFill.heart);
final _sale = NavItem('/sale', 'Sale', PhosphorIconsRegular.tag, PhosphorIconsFill.tag);
final _ranking = NavItem('/ranking', 'Ranking', PhosphorIconsRegular.listNumbers, PhosphorIconsFill.listNumbers);
final _recent = NavItem('/recent', 'Recent Releases', PhosphorIconsRegular.calendarCheck, PhosphorIconsFill.calendarCheck);
final _soon = NavItem('/coming-soon', 'Coming Soon', PhosphorIconsRegular.hourglass, PhosphorIconsFill.hourglass);

/// Phone bar order.
final phoneNav = [_highlights, _search, _sale, _ranking, _wish];

/// Sidebar order: the store's sections, then Recent Releases and Coming Soon.
final sidebarPrimary = [_highlights, _search, _wish];
final sidebarSecondary = [_sale, _ranking, _recent, _soon];

const sidebarBreakpoint = 840.0;

/// Which nav path the current location belongs to.
String currentSection(String location, {required bool sidebar}) {
  if (location == '/') return '/';
  for (final p in ['/search', '/sale', '/ranking', '/wish-list', '/recent', '/coming-soon']) {
    if (location == p || location.startsWith('$p/')) {
      // on a phone the two release lists live under Highlights
      if (!sidebar && (p == '/recent' || p == '/coming-soon')) return '/';
      return p;
    }
  }
  return '';
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= sidebarBreakpoint;
    return wide ? _WideShell(location: location, child: child) : _PhoneShell(location: location, child: child);
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({this.size = 18});
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsBold.target, color: Colors.white, size: size + 4),
          const SizedBox(width: 8),
          Text('Ringgit Radar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size, height: 1.1)),
        ],
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return RingTarget(
      radius: size / 2,
      label: 'About Ringgit Radar',
      onTap: () => context.go('/about'),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tk.card,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: ExcludeSemantics(child: Icon(PhosphorIconsRegular.user, size: size * 0.5, color: tk.text)),
      ),
    );
  }
}

class _PhoneShell extends StatelessWidget {
  const _PhoneShell({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final current = currentSection(location, sidebar: false);
    return Scaffold(
      backgroundColor: tk.content,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Semantics(
                        header: true,
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.only(left: 16, right: 18),
                          decoration: const BoxDecoration(color: brandRed, borderRadius: BorderRadius.horizontal(right: Radius.circular(4))),
                          alignment: Alignment.center,
                          child: const _Wordmark(),
                        ),
                      ),
                      const Spacer(),
                      const _Avatar(),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
          Positioned(left: 16, right: 16, bottom: 0, child: SafeArea(top: false, minimum: const EdgeInsets.only(bottom: 12), child: _BottomBar(current: current))),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: tk.card,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: tk.isDark ? 0.5 : 0.2), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Semantics(
        container: true,
        label: 'Sections',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              for (final item in phoneNav)
                Expanded(child: _BarItem(item: item, selected: item.path == current)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.item, required this.selected});

  final NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return RingTarget(
      radius: 26,
      selected: selected,
      label: item.label,
      onTap: () => context.go(item.path),
      child: SizedBox(
        height: 64,
        child: ExcludeSemantics(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: selected ? 26 : 0,
                    height: 4,
                    decoration: const BoxDecoration(color: brandRed, borderRadius: BorderRadius.vertical(bottom: Radius.circular(3))),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(selected ? item.iconFilled : item.icon, size: 24, color: tk.text),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(item.label,
                          maxLines: 1,
                          style: TextStyle(fontSize: 11, height: 1.1, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: tk.text)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideShell extends StatelessWidget {
  const _WideShell({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final width = MediaQuery.sizeOf(context).width;
    final sideWidth = (width * 0.25).clamp(260.0, 420.0);
    final current = currentSection(location, sidebar: true);
    return Scaffold(
      backgroundColor: tk.content,
      body: Row(
        children: [
          Container(
            width: sideWidth,
            color: tk.sidebar,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Container(height: 64, color: brandRed, padding: const EdgeInsets.symmetric(horizontal: 24), alignment: Alignment.centerLeft, child: const _Wordmark(size: 20)),
                ),
                const SizedBox(height: 12),
                for (final item in sidebarPrimary) _SideRow(item: item, selected: item.path == current, primary: true),
                const SizedBox(height: 8),
                for (final item in sidebarSecondary) _SideRow(item: item, selected: item.path == current, primary: false),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 76, child: Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(right: 24), child: const _Avatar(size: 48)))),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideRow extends StatelessWidget {
  const _SideRow({required this.item, required this.selected, required this.primary});

  final NavItem item;
  final bool selected;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: RingTarget(
        radius: 10,
        selected: selected,
        label: item.label,
        onTap: () => context.go(item.path),
        child: Container(
          height: primary ? 60 : 50,
          decoration: BoxDecoration(color: selected ? tk.card : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: ExcludeSemantics(
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 32,
                  margin: const EdgeInsets.only(left: 10, right: 14),
                  decoration: BoxDecoration(color: selected ? brandRed : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                ),
                if (primary) ...[Icon(selected ? item.iconFilled : item.icon, size: 26, color: tk.text), const SizedBox(width: 16)] else const SizedBox(width: 42),
                Expanded(
                  child: Text(item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: primary ? 20 : 17, fontWeight: selected ? FontWeight.w700 : FontWeight.w400, color: tk.text)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
