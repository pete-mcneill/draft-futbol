import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/substitutes/domain/sub.dart';

class SubsData {
  SubsData({
    this.subsModeActive = false,
    this.subsInProgress = false,
    this.subsToSave = false,
    this.cancelSubs = false,
    this.subs = const {}
  });

  /// All the items in the shopping cart, where:
  /// - key: product ID
  /// - value: quantity
  bool subsModeActive = false;
  bool subsInProgress = false;
  bool subsToSave = false;
  bool cancelSubs = false;
  Map<int, Map<int, List<Sub>>> subs = {};


    SubsData copyWith({
    bool? subsModeActive,
    bool? subsToSave,
    bool? subsInProgress,
    bool? cancelSubs,
    Map<int, Map<int, List<Sub>>>? subs,
  }) {
    return SubsData(
      subsModeActive: subsModeActive ?? this.subsModeActive,
      subsInProgress: subsInProgress ?? this.subsInProgress,
      subsToSave: subsToSave ?? this.subsToSave,
      cancelSubs: cancelSubs ?? this.cancelSubs,
      subs: subs ?? this.subs,
    );
  }
}