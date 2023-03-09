import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'draft_player.dart';

class DraftSquadsNotifier extends StateNotifier<DraftSquads> {
  DraftSquadsNotifier() : super(DraftSquads());
  void getAllSquads(var players, String leagueId, Map<int, DraftPlayer> draftPlayers) {
    state.squads[leagueId] = {};
    for (var player in players) {
      try {
        DraftPlayer _player = draftPlayers[player['element']]!;
        if(state.squads[leagueId]![player['element'].toString()] != null){
          state.squads[leagueId]![player['element'].toString()]!.players.add(_player);
        } else {
          state.squads[leagueId]![player['element'].toString()]!.players = [_player];
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class DraftSquads {
  DraftSquads() : super();

  Map<String, Map<int, DraftSquad>> squads = {};
}

class DraftSquad {
  DraftSquad(
      {required this.players});

  List<DraftPlayer> players;
}
