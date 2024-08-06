import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/league_standings/domain/league_standings_domain.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_leagues.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';

class CupData {
  CupData({
    this.fixtures = const {},
    this.cups = const {},
  });

  /// All the items in the shopping cart, where:
  /// - key: product ID
  /// - value: quantity
  Map<String, Cup> cups = {};
  Map<String, Map<String, List<CupFixture>>> fixtures = {};

  CupData copyWith(
      {Map<String, Map<String, List<CupFixture>>>? fixtures,
      Map<String, Cup>? cups}) {
    return CupData(
      fixtures: fixtures ?? this.fixtures,
      cups: cups ?? this.cups,
    );
  }
}
