import 'package:hive/hive.dart';

import '../models/draft_subs.dart';

class SubsService {
  Map<int, DraftSub> getSubsForTeam(int teamId) {
    Map<int, DraftSub> subs = Hive.box('subs').toMap().cast<int, DraftSub>();
    Map<int, DraftSub> _subs = {};
    subs.forEach((key, value) {
      if (value.teamId == teamId) {
        _subs[key] = (value);
      }
    });
    return _subs;
  }

  Future<Map<int, DraftSub>> removeSelectedSubs(Map<int, DraftSub> subsToRemove, int teamId) async {
    for (var sub in subsToRemove.entries) {
      await Hive.box('subs').delete(sub.key);
    }
    Map<int, DraftSub> updatedSubs = Hive.box('subs').toMap().cast<int, DraftSub>();
    updatedSubs.removeWhere((key, value) => value.teamId != teamId);
    return updatedSubs;
  }
}
