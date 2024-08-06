import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_player.dart';
import 'package:draft_futbol/src/features/live_data/domain/draft_domains/draft_team.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/live_data.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_data.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_match.dart';
import 'package:draft_futbol/src/features/live_data/domain/premier_league_domains/pl_teams.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:draft_futbol/src/features/substitutes/domain/sub.dart';
import 'package:draft_futbol/src/features/substitutes/domain/subs_state.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subs_controller.g.dart';

@Riverpod(keepAlive: true)
class SubsController extends _$SubsController {
  // State monitors if making subs mode is active
  @override
  SubsData build() {
    return SubsData();
  }

  bool get getSubsMode => state.subsModeActive;

  bool get subsInProgress => state.subsInProgress;

  void enableCancelSubs() {
    state = state.copyWith(cancelSubs: true);
  }

  void disableCancelSubs() {
    state = state.copyWith(cancelSubs: false);
  }

  void enableSubsInprogress() {
    state = state.copyWith(subsInProgress: true);
  }

  void disableSubsInprogress() {
    state = state.copyWith(subsInProgress: false);
  }

  void enableSubsMode() {
    state = state.copyWith(subsModeActive: true);
  }

  void disableSubsMode(int teamId) {
    try {
      int currentGameweek =
          ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
      Map<int, Map<int, List<Sub>>> subs = Map.from(state.subs);
      subs[currentGameweek]!.removeWhere((key, value) => key == teamId);
      state = state.copyWith(subsModeActive: false, subs: subs);
    } catch (e) {
      print(e);
      state = state.copyWith(subsModeActive: false);
    }
    ;
  }

  void enableSubsToSave() {
    state = state.copyWith(subsToSave: true);
  }

  void disableSubsToSave() {
    state = state.copyWith(subsToSave: false);
  }

  bool checkForSubsForTeam(DraftTeam team) {
    int currentGameweek =
        ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
    Map<dynamic, dynamic> savedSubs = Hive.box('subs').toMap();
    Map<int, Map<int, List<Sub>>> stateSubs = state.subs;
    if (savedSubs[currentGameweek] == null) {
      return false;
    } else if (savedSubs[currentGameweek]![team.id] != null) {
      return true;
    } else if (stateSubs[currentGameweek] == null) {
      return false;
    } else if (stateSubs[currentGameweek]![team.id] != null) {
      return true;
    } else {
      return false;
    }
  }

  void addSub(Sub sub, DraftTeam team) {
    try {
      int currentGameweek =
          ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
      Map<int, Map<int, List<Sub>>> subs =
          Map<int, Map<int, List<Sub>>>.from(state.subs);
      if (subs[currentGameweek] == null) {
        subs[currentGameweek] = {
          team.id!: [sub]
        };
      } else if (subs[currentGameweek]![team.id] == null) {
        subs[currentGameweek]![team.id!] = [sub];
      } else {
        subs[currentGameweek]![team.id]!.add(sub);
      }
      state = state.copyWith(subs: subs);
    } catch (e) {
      print(e);
    }
  }

  void removeSub(DraftTeam team) {
    try {
      int currentGameweek =
          ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
      Map<int, Map<int, List<Sub>>> subs =
          Map<int, Map<int, List<Sub>>>.from(state.subs);
      subs[currentGameweek]!.removeWhere((key, value) => key == team.id);
      state = state.copyWith(subs: subs);
    } catch (e) {
      print(e);
    }
  }

  void saveSubs(DraftTeam team) {
    try {
      int currentGameweek =
          ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
      Map<int, List<Sub>> allStateSubs = state.subs[currentGameweek]!;
      List<Sub> subs = allStateSubs[team.id] ?? [];
      Map<dynamic, dynamic> allSubs = Hive.box('subs').toMap();
      for (Sub sub in subs) {
        if (allSubs[currentGameweek] == null) {
          allSubs[currentGameweek] = {
            team.id!: [sub]
          };
        } else if (allSubs[currentGameweek]![team.id] == null) {
          allSubs[currentGameweek]![team.id!] = [sub];
        } else {
          allSubs[currentGameweek]![team.id]!.add(sub);
        }
      }
      Hive.box('subs').put(currentGameweek, allSubs[currentGameweek]!);
    } catch (e) {
      print(e);
    }
  }

  void resetTeamSubs(DraftTeam team) {
    try {
      int currentGameweek =
          ref.read(liveDataControllerProvider).gameweek!.currentGameweek;
      Map<dynamic, dynamic> allSubs = Hive.box('subs').toMap();
      Map<dynamic, dynamic> teamSubs = allSubs[currentGameweek] ?? {};
      teamSubs.removeWhere((key, value) => key == team.id);
      Hive.box('subs').put(currentGameweek, teamSubs);
    } catch (e) {
      print(e);
    }
  }
}
