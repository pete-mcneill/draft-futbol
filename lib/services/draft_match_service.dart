import '../models/draft_player.dart';
import '../models/pl_match.dart';
import '../models/players/bps.dart';
import '../models/players/match.dart';
import '../models/players/stat.dart';

class DraftMatchService {
  Map<int, DraftPlayer> updateLiveBonusPoints(
      Map<int, PlMatch> plMatches, Map<int, DraftPlayer> players) {
    try {
      players.forEach((id, DraftPlayer player) {
        if (player.matches != null) {
          for (PlMatchStats match in player.matches!) {
            PlMatch plMatch = plMatches[match.matchId]!;
            if (plMatch.started! && !plMatch.finished!) {
              Map<int, List<Bps>> bps = plMatch.bpsPlayers;
              Iterable threeBps =
                  bps[3]!.where((Bps i) => i.element == player.playerId);
              if (threeBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 3, value: 3);
                match.stats!.add(_stat);
              }
              Iterable twoBps =
                  bps[2]!.where((Bps i) => i.element == player.playerId);
              if (twoBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 2, value: 2);
                match.stats!.add(_stat);
              }
              Iterable oneBps =
                  bps[1]!.where((Bps i) => i.element == player.playerId);
              if (oneBps.isNotEmpty) {
                Stat _stat = Stat(
                    statName: "Live Bonus Points", fantasyPoints: 1, value: 1);
                match.stats!.add(_stat);
              }
            }
          }
        }
      });
      return players;
    } catch (error) {
      print(error);
      return players;
    }
  }
}
