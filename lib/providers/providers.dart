import 'dart:convert';

import 'package:draft_futbol/models/DraftTeam.dart';
import 'package:draft_futbol/models/Gameweek.dart';
import 'package:draft_futbol/models/draft_leagues.dart';
import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/models/draft_squad.dart';
import 'package:draft_futbol/models/fixture.dart';
import 'package:draft_futbol/models/league_standing.dart';
import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/pl_teams.dart';
import 'package:draft_futbol/models/purchases.dart';
import 'package:draft_futbol/models/trades.dart';
import 'package:draft_futbol/models/transactions.dart';
import 'package:draft_futbol/services/api_service.dart';
import 'package:draft_futbol/services/utils_service.dart';
import 'package:draft_futbol/utils/utilities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final _api = Api();

class GameweekNotifier extends StateNotifier<Gameweek?> {
  GameweekNotifier() : super(null);

  void setGameweek(Gameweek gameweek) {
    state = gameweek;
  }
}

final squadsProvider =
    StateNotifierProvider<DraftSquadsNotifier, DraftSquads>((ref) {
  return DraftSquadsNotifier();
});

final tradesProvider = StateNotifierProvider<TradesNotifier, Trades>((ref) {
  return TradesNotifier();
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, Transactions>((ref) {
  return TransactionsNotifier();
});

final purchasesProvider =
    StateNotifierProvider<PurchasesNotifier, DraftPurchases>((ref) {
  return PurchasesNotifier();
});

final utilsProvider =
    StateNotifierProvider<UtilitiesProvider, Utilities>((ref) {
  return UtilitiesProvider();
});

final gameweekProvider =
    StateNotifierProvider<GameweekNotifier, Gameweek?>((ref) {
  return GameweekNotifier();
});

final draftLeaguesProvider =
    StateNotifierProvider<DraftLeaguesNotifier, DraftLeagues>((ref) {
  return DraftLeaguesNotifier();
});

final draftTeamsProvider =
    StateNotifierProvider<DraftTeamsNotifier, DraftTeams>((ref) {
  return DraftTeamsNotifier();
});

final draftPlayersProvider =
    StateNotifierProvider<DraftPlayersNotifier, DraftPlayers>((ref) {
  return DraftPlayersNotifier();
});

final classicStandingsProvider = StateNotifierProvider<
    ClassicLeagueStandingsNotifier, ClassicLeagueStandings>((ref) {
  return ClassicLeagueStandingsNotifier();
});

final h2hStandingsProvider =
    StateNotifierProvider<H2HLeagueStandingsNotifier, H2HLeagueStandings>(
        (ref) {
  return H2HLeagueStandingsNotifier();
});

final fixturesProvider =
    StateNotifierProvider<FixturesNotifier, Fixtures>((ref) {
  return FixturesNotifier();
});

final plMatchesProvider =
    StateNotifierProvider<PlMatchesNotifier, PlMatches>((ref) {
  return PlMatchesNotifier();
});

final plTeamsProvider = StateNotifierProvider<PlTeamsNotifier, PlTeams>((ref) {
  return PlTeamsNotifier();
});

Future handleH2HLeague(String leagueId, var leagueData, Gameweek gameweek,
    FutureProviderRef ref, Map<dynamic, dynamic> subs) async {
  await ref
      .read(draftTeamsProvider.notifier)
      .getLeagueSquads(leagueData, gameweek.currentGameweek, leagueId, subs);
  // ref.read(fixturesProvider.notifier).getGwFixtures(
  //     int.parse(gameweek.currentGameweek), leagueData['matches'], leagueId);
  ref
      .read(fixturesProvider.notifier)
      .getAllFixtures(leagueData['matches'], leagueId);
  Map<String, Map<int, DraftTeam>> _squads =
      ref.read(draftTeamsProvider).teams!;
  Map<String, List<Fixture>> GwFixtures =
      ref.read(fixturesProvider).fixtures[leagueId]!;
  List staticStandings = leagueData['standings'];
  ref
      .read(h2hStandingsProvider.notifier)
      .getStaticStandings(staticStandings, _squads[leagueId]!, leagueId);
  if (gameweek.gameweekFinished) {
    ref.read(draftTeamsProvider.notifier).updateFinishedTeamScores(
        GwFixtures[gameweek.currentGameweek]!, leagueId);
  } else {
    ref
        .read(draftTeamsProvider.notifier)
        .updateLiveTeamScores(ref.read(draftPlayersProvider).players);
    Map<String, Map<int, DraftTeam>> teams =
        ref.read(draftTeamsProvider).teams!;
    ref.read(draftTeamsProvider.notifier).calculateRemainingPlayers(
        ref.read(draftPlayersProvider).players,
        ref.read(plMatchesProvider).plMatches!);
    // ref.read(draftTeamsProvider.notifier).makeAutoSubs(
    //     ref.read(draftPlayersProvider).players,
    //     ref.read(plMatchesProvider).plMatches!);
    List liveStandings = json.decode(json.encode(staticStandings));
    List bonusStandings = json.decode(json.encode(staticStandings));
    ref.read(h2hStandingsProvider.notifier).getLiveStandings(
        liveStandings, leagueId, GwFixtures, _squads, gameweek.currentGameweek);
    ref.read(h2hStandingsProvider.notifier).getLiveBonusPointStandings(
        bonusStandings,
        leagueId,
        GwFixtures,
        _squads,
        gameweek.currentGameweek);
  }
}

Future handleClassicLeague(String leagueId, var leagueData, Gameweek gameweek,
    FutureProviderRef ref, Map<dynamic, dynamic> subs) async {
  await ref
      .read(draftTeamsProvider.notifier)
      .getLeagueSquads(leagueData, gameweek.currentGameweek, leagueId, subs);
  Map<String, Map<int, DraftTeam>> _squads =
      ref.read(draftTeamsProvider).teams!;
  ref
      .read(classicStandingsProvider.notifier)
      .getStaticStandings(leagueData['standings'], leagueId, _squads);
  if (gameweek.gameweekFinished) {
    ref
        .read(classicStandingsProvider.notifier)
        .updateFinishedTeamScores(leagueData['standings'], leagueId, _squads);
  } else {
    ref
        .read(draftTeamsProvider.notifier)
        .updateLiveTeamScores(ref.read(draftPlayersProvider).players);
    Map<String, Map<int, DraftTeam>> teams =
        ref.read(draftTeamsProvider).teams!;
    ref.read(draftTeamsProvider.notifier).calculateRemainingPlayers(
        ref.read(draftPlayersProvider).players,
        ref.read(plMatchesProvider).plMatches!);
    List staticStandings = leagueData['standings'];
    List liveStandings = json.decode(json.encode(staticStandings));
    List bonusStandings = json.decode(json.encode(staticStandings));
    ref
        .read(classicStandingsProvider.notifier)
        .getLiveStandings(liveStandings, leagueId, _squads);
    ref
        .read(classicStandingsProvider.notifier)
        .getLiveBonusPointStandings(bonusStandings, leagueId, _squads);
  }
}

final refreshFutureLiveDataProvider = FutureProvider((ref) async {
  try {
    Map<String, dynamic> leagueIds = await setLeagueIds();
    ref.read(utilsProvider.notifier).setLeagueIds(leagueIds);
    ref.read(utilsProvider.notifier).setDefaultActiveLeague();
    ref.read(utilsProvider.notifier).setLeagueIds(leagueIds);
    // Get Data not relevant to Leagues
    Gameweek? _gameweek = await _api.getCurrentGameweek();

    ref.read(gameweekProvider.notifier).setGameweek(_gameweek!);
    var staticData = await _api.getStaticData();
    Map<dynamic, dynamic> subs = {};
    try {
      // await Hive.box('subs').clear();
      // _gameweek!.currentGameweek = "38";
      // Get Subs fom local storage and remove if not for the current GW
      subs = Hive.box('subs').toMap();
      subs.removeWhere(
          (key, value) => value.gameweek != _gameweek.currentGameweek);
      // _gameweek!.currentGameweek = "34";
    } catch (error) {
      print(error);
    }
    // Create all Draft Players
    ref
        .read(draftPlayersProvider.notifier)
        .createAllDraftPlayers(staticData['elements']);

    for (var team in staticData['teams']) {
      PlTeam _team = PlTeam.fromJson(team);
      ref.read(plTeamsProvider.notifier).addPlTeams(_team);
    }
    // Season has not started, Gameweek comes back as Null
    if (_gameweek.currentGameweek != "null") {
      var liveData = await _api.getLiveData(_gameweek.currentGameweek);
      ref.read(draftPlayersProvider.notifier).getLivePlayerData(liveData);

      await ref
          .read(plMatchesProvider.notifier)
          .getLivePlFixtures(staticData, liveData);
      ref
          .read(draftPlayersProvider.notifier)
          .updateLiveBonusPoints(ref.read(plMatchesProvider).plMatches!);
    }
    // Get League IDs
    // For Each league get League Data
    for (String leagueId in leagueIds.keys) {
      var leagueDetails = await _api.getLeagueDetails(leagueId);

      DraftLeague _league = DraftLeague.fromJson(leagueDetails);
      ref.read(draftLeaguesProvider.notifier).addLeague(_league);
      String leagueType = leagueDetails['league']['scoring'];
      String draftStatus = leagueDetails['league']['draft_status'];
      if (draftStatus != "pre") {
        if (_gameweek.currentGameweek != "null") {
          if (leagueType == 'h') {
            await handleH2HLeague(
                leagueId, leagueDetails, _gameweek, ref, subs);
          } else {
            await handleClassicLeague(
                leagueId, leagueDetails, _gameweek, ref, subs);
          }
        }
      }
    }

    int advertRefresh = Hive.box('adverts').get("adCounter");
    advertRefresh += 1;
    Hive.box('adverts').put('adCounter', advertRefresh);
    return;
  } catch (e) {
    print(e);
  }
});

final futureLiveDataProvider = FutureProvider((ref) async {
  try {
    Map<String, dynamic> leagueIds = await setLeagueIds();
    ref.read(utilsProvider.notifier).setLeagueIds(leagueIds);
    ref.read(utilsProvider.notifier).setDefaultActiveLeague();
    ref.read(utilsProvider.notifier).setLeagueIds(leagueIds);
    // Get Data not relevant to Leagues
    Gameweek? _gameweek = await _api.getCurrentGameweek();
    ref.read(gameweekProvider.notifier).setGameweek(_gameweek!);
    var staticData = await _api.getStaticData();
    Map<dynamic, dynamic> subs = {};
    try {
      // Hive.box('subs').clear();
      // Get Subs fom local storage and remove if not for the current GW
      subs = Hive.box('subs').toMap();
      subs.removeWhere(
          (key, value) => value.gameweek != _gameweek.currentGameweek);
    } catch (error) {
      print(error);
    }

    // Create all Draft Players
    ref
        .read(draftPlayersProvider.notifier)
        .createAllDraftPlayers(staticData['elements']);

    for (var team in staticData['teams']) {
      PlTeam _team = PlTeam.fromJson(team);
      ref.read(plTeamsProvider.notifier).addPlTeams(_team);
    }
    // Season has not started, Gameweek comes back as Null
    if (_gameweek.currentGameweek != "null") {
      var liveData = await _api.getLiveData(_gameweek.currentGameweek);
      ref.read(draftPlayersProvider.notifier).getLivePlayerData(liveData);

      await ref
          .read(plMatchesProvider.notifier)
          .getLivePlFixtures(staticData, liveData);
      ref
          .read(draftPlayersProvider.notifier)
          .updateLiveBonusPoints(ref.read(plMatchesProvider).plMatches!);
    } else {
      await ref.read(plMatchesProvider.notifier).getPlFixtures(staticData, "1");
      print("GOT");
    }
    // Get League IDs
    // For Each league get League Data
    for (String leagueId in leagueIds.keys) {
      var leagueDetails = await _api.getLeagueDetails(leagueId);
      var playerStatus = await _api.getPlayerStatus(leagueId);
      ref
          .read(draftPlayersProvider.notifier)
          .setPlayerStatus(playerStatus!['element_status'], leagueId);
      DraftLeague _league = DraftLeague.fromJson(leagueDetails);
      ref.read(draftLeaguesProvider.notifier).addLeague(_league);
      String leagueType = leagueDetails['league']['scoring'];
      String draftStatus = leagueDetails['league']['draft_status'];
      if (draftStatus != "pre") {
        if (_gameweek.currentGameweek != "null") {
          if (leagueType == 'h') {
            await handleH2HLeague(
                leagueId, leagueDetails, _gameweek, ref, subs);
          } else {
            await handleClassicLeague(
                leagueId, leagueDetails, _gameweek, ref, subs);
          }
        }
      }
    }

    int advertRefresh = Hive.box('adverts').get("adCounter");
    advertRefresh += 1;
    Hive.box('adverts').put('adCounter', advertRefresh);
    return;
  } catch (e) {
    print(e);
  }
});

final allTransactions = FutureProvider((ref) async {
  try {
    Map<String, DraftLeague> leagues = ref.read(draftLeaguesProvider).leagues;
    for (String leagueId in leagues.keys) {
      var transactions = await _api.getTransactions(leagueId);
      ref
          .read(transactionsProvider.notifier)
          .addAllTransactions(transactions!['transactions'], leagueId);
      // var trades = await _api.getLeagueTrades(leagueId);
      // ref.read(transactionsProvider.notifier).addAllTrades(trades['transactions'], leagueId);
    }
  } catch (Exception) {
    print(Exception);
  }
});

final allTrades = FutureProvider((ref) async {
  try {
    Map<String, DraftLeague> leagues = ref.read(draftLeaguesProvider).leagues;
    for (String leagueId in leagues.keys) {
      var trades = await _api.getLeagueTrades(leagueId);
      ref.read(tradesProvider.notifier).addAllTrades(trades, leagueId);
    }
  } catch (Exception) {
    print(Exception);
  }
});

final allSquads = FutureProvider((ref) async {
  try {
    Map<String, DraftLeague> leagues = ref.read(draftLeaguesProvider).leagues;
    Map<int, DraftPlayer> players = ref.read(draftPlayersProvider).players;
    for (String leagueId in leagues.keys) {
      var playersStatus = await _api.getPlayerStatus(leagueId);
      ref
          .read(squadsProvider.notifier)
          .getAllSquads(playersStatus, leagueId, players);
    }
  } catch (Exception) {
    print(Exception);
  }
});
