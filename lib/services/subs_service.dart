import 'package:draft_futbol/models/pl_match.dart';
import 'package:draft_futbol/models/players/match.dart';
import 'package:hive/hive.dart';

import '../models/draft_player.dart';
import '../models/draft_team.dart';
import '../models/players/stat.dart';
import '../models/sub.dart';

class SubsService {
  Map<int, Sub> getSubsForTeam(int teamId) {
    Map<int, Sub> subs = Hive.box('gwSubs').toMap().cast<int, Sub>();
    Map<int, Sub> _subs = {};
    subs.forEach((key, value) {
      if (value.teamId == teamId) {
        _subs[key] = (value);
      }
    });
    return _subs;
  }

  Future<Map<int, Sub>> removeSelectedSubs(
      Map<int, Sub> subsToRemove, int teamId) async {
    for (var sub in subsToRemove.entries) {
      await Hive.box('gwSubs').delete(sub.key);
    }
    Map<int, Sub> updatedSubs = Hive.box('gwSubs').toMap().cast<int, Sub>();
    updatedSubs.removeWhere((key, value) => value.teamId != teamId);
    return updatedSubs;
  }

  Map<int, DraftTeam> previewSubScores(Map<int, DraftPlayer> players,
      Map<int, DraftTeam> teams, List<Sub> subs) {
    for (Sub sub in subs) {
      DraftTeam _team = teams[sub.teamId]!;
      DraftPlayer _subIn = players[sub.subInId]!;
      DraftPlayer _subOut = players[sub.subOutId]!;
      var (subInScore, subInBonusScore) = getSubLiveBonusPoints(_subIn, _team);
      var (subOutScore, subOutBonusScore) =
          getSubLiveBonusPoints(_subOut, _team);
      _team.points = _team.points! - subOutScore;
      _team.points = _team.points! + subInScore;
    }
    return teams;
  }

  (int, int) getSubLiveBonusPoints(
    DraftPlayer player,
    DraftTeam team,
  ) {
    int score = 0;
    int bonusScore = 0;
    for (PlMatchStats match in player.matches!) {
      for (Stat stat in match.stats!) {
        if (stat.statName != "Live Bonus Points") {
          score += stat.fantasyPoints!;
          bonusScore += stat.fantasyPoints!;
        } else {
          bonusScore += stat.fantasyPoints!;
        }
      }
    }
    return (score, bonusScore);
  }
}
