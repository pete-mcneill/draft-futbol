import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'draft_player.dart';

class DraftSquadsNotifier extends StateNotifier<DraftSquads> {
  DraftSquadsNotifier() : super(DraftSquads());
  void getAllSquads(
      var players, int leagueId, Map<int, DraftPlayer> draftPlayers) {
    state.squads[leagueId] = {};
    for (var player in players['element_status']) {
      try {
        DraftPlayer _player = draftPlayers[player['element']]!;
        if (player['owner'] != null) {
          if (state.squads[leagueId]![player['owner'].toString()] != null) {
            state.squads[leagueId]![player['owner'].toString()]!.players
                .add(_player);
          } else {
            state.squads[leagueId] = {
              player['owner']: DraftSquad(players: [_player])
            };
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class DraftSquads {
  DraftSquads() : super();

  Map<int, Map<int, DraftSquad>> squads = {};
}

class DraftSquad {
  DraftSquad({required this.players});

  List<DraftPlayer> players;
}
