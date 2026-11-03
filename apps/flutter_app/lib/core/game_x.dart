import 'api/models.dart';
import 'format.dart';

/// What the router carries to the game page so art and title show before the detail arrives.
class GameRouteExtra {
  const GameRouteExtra({required this.game, required this.heroTag});
  final Game game;
  final String heroTag;
}

extension GameLabels on Game {
  /// Released in the 30 days up to and including today, Malaysia time.
  bool isNewAt(DateTime now) {
    final r = releaseDate == null ? null : DateTime.tryParse(releaseDate!);
    if (r == null) return false;
    final today = todayMyt(now);
    final released = DateTime.utc(r.year, r.month, r.day);
    return !released.isAfter(today) && today.difference(released).inDays <= 30;
  }

  bool isUpcomingAt(DateTime now) {
    final r = releaseDate == null ? null : DateTime.tryParse(releaseDate!);
    if (r == null) return isUnreleased || isPreorder;
    return DateTime.utc(r.year, r.month, r.day).isAfter(todayMyt(now));
  }

  /// What stands where a price would be when there is none.
  String noPriceLabel(DateTime now) {
    if (isUpcomingAt(now)) {
      if (releaseDate != null) return releaseDateLabel(releaseDate!);
      if (releaseText.isNotEmpty) return releaseText;
      return 'Coming soon';
    }
    return 'Price unavailable';
  }

  String get kindLabel => switch (category) {
        'bundle' => 'Bundle',
        'addon' => 'Add-on',
        _ => '',
      };

  String get platformLabel => switch (platform) {
        'switch2' => 'Switch 2',
        'switch' => 'Switch',
        _ => '',
      };
}
