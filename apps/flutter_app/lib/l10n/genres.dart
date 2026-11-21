import 'app_localizations.dart';

/// The shown name of a genre the API sends in English (the list from /v1/genres). The API value stays the
/// filter value; only the label changes. A genre this list does not know shows exactly as sent.
String genreLabel(AppLocalizations l, String apiName) => switch (apiName) {
    'Action' => l.genreAction,
    'Adventure' => l.genreAdventure,
    'Puzzle' => l.genrePuzzle,
    'Simulation' => l.genreSimulation,
    'Arcade' => l.genreArcade,
    'RPG' => l.genreRpg,
    'Strategy' => l.genreStrategy,
    'Other' => l.genreOther,
    'Platformer' => l.genrePlatformer,
    'Shooter' => l.genreShooter,
    'Party' => l.genreParty,
    'Multiplayer' => l.genreMultiplayer,
    'Racing' => l.genreRacing,
    'Sports' => l.genreSports,
    'Board Game' => l.genreBoardGame,
    'Fighting' => l.genreFighting,
    'Lifestyle' => l.genreLifestyle,
    'Communication' => l.genreCommunication,
    'Education' => l.genreEducation,
    'Training' => l.genreTraining,
    'Study' => l.genreStudy,
    'Utility' => l.genreUtility,
    'First-Person Shooter' => l.genreFirstPersonShooter,
    'Music' => l.genreMusic,
    'Practical' => l.genrePractical,
    'Video' => l.genreVideo,
    _ => apiName,
  };
