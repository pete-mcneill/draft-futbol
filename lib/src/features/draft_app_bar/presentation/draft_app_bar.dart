import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_button.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/bonus_points/presentation/tempButton.dart';
import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
import 'package:draft_futbol/src/features/draft_app_bar/presentation/draft_app_bar_controller.dart';
import 'package:draft_futbol/src/features/local_storage/data/hive_data_store.dart';
import 'package:draft_futbol/src/features/local_storage/domain/local_league_metadata.dart';
import 'package:draft_futbol/src/features/search/presentation/search_screen.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:draft_futbol/src/features/settings/presentation/settings_screen.dart';
import 'package:draft_futbol/src/utils/async_value_ui.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DraftAppBarV1 extends ConsumerWidget implements PreferredSizeWidget {
  final bool settings;
  final bool leading;
  final bool bottomTabBar;
  final TabController? tabController;
  final TabController? cupTabController;
  String? title;
  int? bottomIndex;
  bool? cupGameweek;

  DraftAppBarV1(
      {Key? key,
      this.settings = false,
      this.title,
      this.leading = false,
      this.bottomTabBar = true,
      this.tabController = null,
      this.bottomIndex = 0,
      this.cupGameweek = false,
      this.cupTabController = null})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  List<LocalLeagueMetadata> leaguesMetadata = [];
  late String dropdownValue;
  bool showBpsButton = true;
  late DraftAppBarController appBarController;
  late TabController _tabController;
  late TabController _cupTabController;
  late Color indicatorColor;

  PreferredSize? createBottomBar(WidgetRef ref) {
    if (bottomTabBar) {
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
                appBarController.updateActiveLeague(
                    leagues[int.parse(index)].id.toString());
              }
            });
            if (bottomIndex != 2) {
              if (bottomIndex == 3 && cupGameweek!) {
                return Text("Premier League Matches");
              } else {
                for (LocalLeagueMetadata league in leaguesMetadata) {
                  tabs.add(Tab(text: league.name));
                }
                return TabBar(
                    controller: _tabController,
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.3),
                    labelColor: Colors.white,
                    indicatorColor: indicatorColor,
                    tabs: tabs);
              }
            } else if (bottomIndex == 2 && cupGameweek!) {
              List<Cup> cups = ref
                  .watch(cupDataControllerProvider.notifier)
                  .getCupsForCurrentGameweek();
              for (Cup cup in cups) {
                tabs.add(Tab(text: cup.name));
              }
              return TabBar(
                  controller: _cupTabController,
                  tabAlignment: TabAlignment.center,
                  isScrollable: true,
                  unselectedLabelColor: Colors.white.withOpacity(0.3),
                  labelColor: Colors.white,
                  indicatorColor: indicatorColor,
                  tabs: tabs);
            } else {
              return Text("Premier League Matches");
            }
          }),
          preferredSize: Size.fromHeight(30.0));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appBarController = ref.read(draftAppBarControllerProvider.notifier);

    if (bottomTabBar) {
      _tabController = tabController!;
      indicatorColor = Theme.of(context).colorScheme.secondaryContainer;
      leaguesMetadata = ref.read(dataStoreProvider).getLeagues();
    }

    if (cupGameweek!) {
      _cupTabController = cupTabController!;
    }

    ref.listen<AsyncValue<void>>(
      draftAppBarControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(draftAppBarControllerProvider);

    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: leading,
      leading: !leading
          ? IconButton(
              icon: const Icon(FontAwesomeIcons.magnifyingGlass),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            )
          : null,
      elevation: 3,
      title: Image.asset("assets/images/1024_1024-icon.png",
          height: 30, width: 30),
      bottom: bottomTabBar ? createBottomBar(ref) : null,
      // getDropdownTitle(),
      actions: [
        if (!appBarController.gameweekFinished) const BonusPointsToggle(),
      ],
    );
  }
}
