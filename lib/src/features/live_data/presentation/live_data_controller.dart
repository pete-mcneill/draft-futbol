import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:draft_futbol/src/features/live_data/domain/live_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'live_data_controller.g.dart';

@Riverpod(keepAlive: true)
class LiveDataController extends _$LiveDataController {
  @override
  LiveData build() {
    return LiveData();
  }

  Gameweek get getGameweek => state.gameweek!;

  void setGameweek(Gameweek gameweek) {
    state.gameweek = gameweek;
  }

}