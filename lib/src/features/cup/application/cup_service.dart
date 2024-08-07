import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/application/api_service.dart';
import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/features/live_data/data/premier_league_repository.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/presentation/draft_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/live_data/presentation/premier_league_controller.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/match.dart';
import 'package:draft_futbol/src/features/premier_league_matches/domain/stat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cup_service.g.dart';

class CupService {
  CupService(this.ref);
  final Ref ref;

  final _api = Api();

  Future<void> getCups() async {
    final cups = Hive.box('cups').values.cast();
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    for (Cup cup in cups) {
      ref.read(cupDataControllerProvider.notifier).setCupState(cup);
      for (var round in cup.rounds) {
        print(round);
        if (round['multipleLegs']) {
          if (round['gameweek'] == gameweek.currentGameweek ||
              round['secondGameweek'] == gameweek.currentGameweek) {
            calculateAggregateRoundScores(cup, round);
          }
        } else {
          if (round['gameweek'] == gameweek.currentGameweek) {
            List<CupFixture> fixtures = [];
            for (CupFixture fixture in cup.fixtures[round['id']]!) {
              DraftTeam homeTeam = ref
                  .read(draftDataControllerProvider)
                  .teams[fixture.homeTeamId]!;
              DraftTeam awayTeam = ref
                  .read(draftDataControllerProvider)
                  .teams[fixture.awayTeamId]!;
              CupFixture cupFixture = CupFixture(
                  homeTeamId: homeTeam.id!,
                  awayTeamId: awayTeam.id!,
                  homeScore: homeTeam.points,
                  homeBonusScore: homeTeam.bonusPoints,
                  awayScore: awayTeam.points,
                  awayBonusScore: awayTeam.bonusPoints);
              fixtures.add(cupFixture);
            }
            ref
                .read(cupDataControllerProvider.notifier)
                .updateFixtures(cup.name, round['id'], fixtures);
          }
        }
      }
    }
    print(cups);
  }

  Future<Map<String, List<CupFixture>>> getScoresForCup(Cup cup) async {
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    Map<String, List<CupFixture>> fixtures = {};
    for (var round in cup.rounds) {
      if (cup.fixtures[round['id']] != null) {
        if (round['multipleLegs']) {
          if (round['gameweek'] < gameweek.currentGameweek &&
              round['secondGameweek'] < gameweek.currentGameweek &&
              round['secondGameweek'] != round['gameweek']) {
            fixtures[round['id']] = await getFixtureScoreForMultipleLegs(
                round, round['gameweek'], round['secondGameweek'], cup);
          } else if (round['gameweek'] < gameweek.currentGameweek) {
            fixtures[round['id']] = await getFixtureScoreForLeg(round, cup);
          }
        } else {
          if (round['gameweek'] < gameweek.currentGameweek) {
            fixtures[round['id']] = await getFixtureScoreForLeg(round, cup);
          }
        }
      }
    }
    return fixtures;
  }

  Future<List<CupFixture>> getFixtureScoreForMultipleLegs(
      dynamic round, int firstLeg, int secondLeg, Cup cup) async {
    List<CupFixture> fixtures = [];
    final firstLegData = await _api.getLiveData(firstLeg);
    final secondLegData = await _api.getLiveData(secondLeg);
    Map<int, DraftPlayer> players =
        Map.from(ref.read(premierLeagueControllerProvider).players);
    players = await getLivePlayerData(firstLegData, players, firstLeg);
    players = await getLivePlayerData(secondLegData, players, secondLeg);
    for (CupFixture fixture in cup.fixtures[round['id']]!) {
      int firstLegHomeScore =
          await getTeamScore(fixture.homeTeamId, firstLeg, players);
      int firstLegAwayScore =
          await getTeamScore(fixture.awayTeamId, firstLeg, players);
      int secondLegHomeScore =
          await getTeamScore(fixture.homeTeamId, secondLeg, players);
      int secondLegAwayScore =
          await getTeamScore(fixture.awayTeamId, secondLeg, players);

      int homeScore = firstLegHomeScore + secondLegHomeScore;
      int awayScore = firstLegAwayScore + secondLegAwayScore;

      CupFixture cupFixture = CupFixture(
          homeTeamId: fixture.awayTeamId,
          awayTeamId: fixture.homeTeamId,
          homeScore: homeScore,
          awayScore: awayScore);
      fixtures.add(cupFixture);
    }
    return fixtures;
  }

  Future<List<CupFixture>> getFixtureScoreForLeg(dynamic round, Cup cup) async {
    List<CupFixture> fixtures = [];
    final roundLiveData = await _api.getLiveData(round['gameweek']);
    Map<int, DraftPlayer> players =
        Map.from(ref.read(premierLeagueControllerProvider).players);
    players =
        await getLivePlayerData(roundLiveData, players, round['gameweek']);
    for (CupFixture fixture in cup.fixtures[round['id']]!) {
      int homeScore =
          await getTeamScore(fixture.homeTeamId, round['gameweek'], players);
      int awayScore =
          await getTeamScore(fixture.awayTeamId, round['gameweek'], players);
      CupFixture cupFixture = CupFixture(
          homeTeamId: fixture.awayTeamId,
          awayTeamId: fixture.homeTeamId,
          homeScore: homeScore,
          awayScore: awayScore);
      fixtures.add(cupFixture);
    }
    return fixtures;
  }

  Future<int> getTeamScore(
      int teamId, int gameweek, Map<int, DraftPlayer> players) async {
    DraftTeam team = ref.read(draftDataControllerProvider).teams[teamId]!;
    var homeSquad = await _api.getSquad(team.entryId!, gameweek);
    Map<int, int>? _homeSquad = {};
    for (var player in homeSquad['picks']) {
      _homeSquad[player['element']] = player['position'];
    }
    int score = getFirstLegScore(_homeSquad, players, gameweek);
    return score;
  }

  Future<Map<int, DraftPlayer>> getLivePlayerData(
      var liveData, Map<int, DraftPlayer> players, int gameweek) async {
    try {
      liveData['elements'].forEach((k, v) {
        List<PlMatchStats> _matches = [];
        for (var liveMatch in v['explain']) {
          PlMatchStats _match = PlMatchStats.fromJson(liveMatch);
          _matches.add(_match);
        }
        players[int.parse(k)]!.matches![gameweek] = _matches;
      });
      return players;
    } catch (e) {
      print("Error getting live player data");
      print(e);
      throw e;
    }
  }

  void calculateAggregateRoundScores(Cup cup, dynamic round) async {
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    List<CupFixture> fixtures = [];
    if (round['secondGameweek'] == gameweek.currentGameweek) {
      try {
        final firstLegLiveData = await _api.getLiveData(round['gameweek']);
        Map<int, DraftPlayer> players =
            ref.read(premierLeagueControllerProvider).players;
        players = await ref
            .read(premierLeagueDataRepositoryProvider)
            .getLivePlayerData(firstLegLiveData, players, round['gameweek']);
        ref
            .read(premierLeagueControllerProvider.notifier)
            .setPremierLeaguePlayers(players);
        for (CupFixture fixture in cup.fixtures[round['id']]!) {
          DraftTeam homeTeam =
              ref.read(draftDataControllerProvider).teams[fixture.homeTeamId]!;
          int firstLegHomeScore =
              getFirstLegScore(homeTeam.squad, players, round['gameweek']);
          DraftTeam awayTeam =
              ref.read(draftDataControllerProvider).teams[fixture.awayTeamId]!;
          int firstLegAwayScore =
              getFirstLegScore(awayTeam.squad, players, round['gameweek']);
          CupFixture cupFixture = CupFixture(
              homeTeamId: homeTeam.id!,
              awayTeamId: awayTeam.id!,
              firstLegHomeScore: firstLegHomeScore,
              firstLegAwayScore: firstLegAwayScore,
              homeScore: homeTeam.points,
              homeBonusScore: homeTeam.bonusPoints,
              awayScore: awayTeam.points,
              awayBonusScore: awayTeam.bonusPoints);
          fixtures.add(cupFixture);
        }
        ref
            .read(cupDataControllerProvider.notifier)
            .updateFixtures(cup.name, round['id'], fixtures);
      } on Exception catch (e) {
        print(e);
      }
    } else {
      List<CupFixture> fixtures = [];
      for (CupFixture fixture in cup.fixtures[round['id']]!) {
        DraftTeam homeTeam =
            ref.read(draftDataControllerProvider).teams[fixture.homeTeamId]!;
        DraftTeam awayTeam =
            ref.read(draftDataControllerProvider).teams[fixture.awayTeamId]!;
        CupFixture cupFixture = CupFixture(
            homeTeamId: homeTeam.id!,
            awayTeamId: awayTeam.id!,
            homeScore: homeTeam.points,
            homeBonusScore: homeTeam.bonusPoints,
            awayScore: awayTeam.points,
            awayBonusScore: awayTeam.bonusPoints);
        fixtures.add(cupFixture);
      }
      ref
          .read(cupDataControllerProvider.notifier)
          .updateFixtures(cup.name, round['id'], fixtures);
    }
  }

  int getFirstLegScore(
      Map<int, int>? squad, Map<int, DraftPlayer> players, int gameweek) {
    int score = 0;
    squad!.forEach((int playerId, int position) {
      DraftPlayer _player = players[playerId]!;
      for (PlMatchStats match in _player.matches![gameweek]!) {
        if (position < 12) {
          for (Stat stat in match.stats!) {
            score += stat.fantasyPoints!;
          }
        }
      }
    });
    return score;
  }
}

@Riverpod(keepAlive: true)
CupService cupService(CupServiceRef ref) {
  return CupService(ref);
}
