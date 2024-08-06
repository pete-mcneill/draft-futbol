import 'package:draft_futbol/src/features/league_standings/domain/league_standing.dart';

class LeagueStandings {
  List<LeagueStanding>? staticStandings;
  List<LeagueStanding>? liveStandings;
  List<LeagueStanding>? liveBpsStandings;

  updateStaticStandings(List<LeagueStanding> standings) {
    staticStandings = standings;
  }

  LeagueStandings({this.staticStandings = const [], this.liveStandings = const [], this.liveBpsStandings = const []});
}