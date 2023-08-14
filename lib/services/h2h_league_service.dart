import '../models/DraftTeam.dart';
import '../models/draft_leagues.dart';
import '../models/draft_team.dart';
import '../models/gameweek.dart';
import 'draft_team_service.dart';

class H2HLeagueService {
  void getData(DraftLeague league, Gameweek gameweek) async {
    Map<int, DraftTeam> squads = await DraftTeamService()
        .getLeagueSquads(league, gameweek.currentGameweek, league.leagueId, {});
    print("squads");
  }
}
