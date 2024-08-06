import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/tempButton.dart';
import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/settings/presentation/settings_screen.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CupAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final TabController? tabController;
  final Cup cup;

  CupAppbar({Key? key, required this.tabController, required this.cup})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  List<LocalLeagueMetadata> leaguesMetadata = [];
  late String dropdownValue;
  bool showBpsButton = true;
  late DraftAppBarController appBarController;
  late TabController _tabController;
  late Color indicatorColor;

  PreferredSize? createBottomBar(WidgetRef ref) {
    List<Tab> tabs = [];
    return PreferredSize(
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = _tabController;
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              String index = tabController.index.toString();
              List<LocalLeagueMetadata> leagues = ref
                  .read(draftAppBarControllerProvider.notifier)
                  .leaguesMetadata;
              appBarController
                  .updateActiveLeague(leagues[int.parse(index)].id.toString());
            }
          });
          for (var round in cup.rounds) {
            tabs.add(Tab(text: round['id'].toString()));
          }
          return TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              unselectedLabelColor: Colors.white.withOpacity(0.3),
              labelColor: Colors.white,
              indicatorColor: indicatorColor,
              tabs: tabs);
        }),
        preferredSize: Size.fromHeight(30.0));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _tabController = tabController!;
    indicatorColor = Theme.of(context).colorScheme.secondaryContainer;
    ref.listen<AsyncValue<void>>(
      draftAppBarControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return AppBar(
      centerTitle: true,
      // automaticallyImplyLeading: leading,
      elevation: 3,
      title: Image.asset("assets/images/1024_1024-icon.png",
          height: 30, width: 30),
      bottom: createBottomBar(ref),
      // getDropdownTitle(),
    );
  }
}
