import 'package:draft_futbol/models/pl_teams.dart';

import 'draft_player.dart';

class StaticData {
  StaticData(this.players) : super();

  Map<int, DraftPlayer> players;
  Map<int, PlTeam>? plTeams;
}
