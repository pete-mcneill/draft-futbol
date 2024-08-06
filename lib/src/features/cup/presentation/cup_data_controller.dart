import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_data.dart';
import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:draft_futbol/src/features/fixtures_results/domain/fixture.dart';
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/presentation/live_data_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cup_data_controller.g.dart';

@Riverpod(keepAlive: true)
class CupDataController extends _$CupDataController {
  @override
  CupData build() {
    return CupData();
  }

  void deleteCup(Cup cup) {
    Map<String, Cup> cups = Map.from(state.cups);
    cups.removeWhere((key, value) => value.name == cup.name);
    state = state.copyWith(cups: cups);
  }

  bool isCupGameweek() {
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    for (Cup cup in state.cups.values) {
      if (cup.rounds.any((round) =>
          (round['gameweek'] == gameweek.currentGameweek) ||
          round['secondGameweek'] == gameweek.currentGameweek)) {
        return true;
      }
    }
    return false;
  }

  List<Cup> getCupsForCurrentGameweek() {
    List<Cup> cups = [];
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    for (Cup cup in state.cups.values) {
      if (cup.rounds.any((round) =>
          (round['gameweek'] == gameweek.currentGameweek) ||
          round['secondGameweek'] == gameweek.currentGameweek)) {
        cups.add(cup);
      }
    }
    return cups;
  }

  dynamic getCurrentRoundName(Cup cup) {
    Gameweek gameweek = ref.read(liveDataControllerProvider).gameweek!;
    for (var round in cup.rounds) {
      if ((round['gameweek'] == gameweek.currentGameweek) ||
          round['secondGameweek'] == gameweek.currentGameweek) {
        return round;
      }
    }
    return {};
  }

  void updateFixtures(
      String cupName, String roundName, List<CupFixture> fixtures) {
    Map<String, Map<String, List<CupFixture>>> _fixtures =
        Map.from(state.fixtures);
    if (!_fixtures.containsKey(cupName)) {
      _fixtures[cupName] = {};
      _fixtures[cupName]![roundName] = fixtures;
    } else {
      if (!_fixtures[cupName]!.containsKey(roundName)) {
        _fixtures[cupName]![roundName] = fixtures;
      } else {
        _fixtures[cupName] = {
          roundName: fixtures,
        };
      }
    }
    state = state.copyWith(fixtures: _fixtures);
  }

  void setCupState(Cup cup) {
    Map<String, Cup> cups = Map.from(state.cups);
    cups[cup.name] = cup;
    state = state.copyWith(cups: cups);
  }
}
