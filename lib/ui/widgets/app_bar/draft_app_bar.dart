import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/ui_settings_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftAppBar extends ConsumerStatefulWidget with PreferredSizeWidget {
  final bool bps;
  final bool settings;
  DraftAppBar({Key? key, this.bps = false, this.settings = false})
      : super(key: key);

  @override
  _DraftAppBarState createState() => _DraftAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DraftAppBarState extends ConsumerState<DraftAppBar> {
  List<DropdownMenuItem<String>> menuOptions = [];
  late String dropdownValue;
  bool showBpsButton = true;
  final _controller03 = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    menuOptions = [];
    setupBpsButtonListener();
    setLeagueNamesForDropdown();
    return AppBar(
      elevation: 0,
      title: getDropdownTitle(),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [showBonusPointsButton(), showUISettingsButton()],
        ),
      ],
    );
  }

  Widget getDropdownTitle() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        iconEnabledColor: Theme.of(context).secondaryHeaderColor,
        isExpanded: true,
        items: menuOptions,
        onChanged: (value) {
          ref.read(utilsProvider.notifier).updateActiveLeague(value.toString());
        },
        value: dropdownValue,
        dropdownDecoration:
            BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
      ),
    );
  }

  Widget showBonusPointsButton() {
    if (widget.bps) {
      return AdvancedSwitch(
        activeChild: const Text('BPS'),
        inactiveChild: const Text('BPS'),
        width: 56,
        height: 28,
        controller: _controller03,
        activeColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
      );
    } else {
      return const SizedBox();
    }
  }

  Widget showUISettingsButton() {
    if (widget.settings) {
      return IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Customise UI Settings',
        onPressed: () {
          showDialog<void>(
            context: context,
            barrierDismissible: true, // user must tap button!
            builder: (BuildContext context) {
              return const UiSettingsDialog();
            },
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }

  void setLeagueNamesForDropdown() {
    Map<String, dynamic> leagueIds = ref.watch(utilsProvider).leagueIds!;
    leagueIds.forEach((key, value) {
      menuOptions.add(DropdownMenuItem(
          value: key,
          child: Center(
            child: Text(
              value['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )));
    });
    dropdownValue = ref.watch(
        utilsProvider.select((connection) => connection.activeLeagueId!));
  }

  void setupBpsButtonListener() {
    _controller03.addListener(() {
      if (_controller03.value) {
        ref.watch(utilsProvider.notifier).updateLiveBps(true);
      } else {
        ref.watch(utilsProvider.notifier).updateLiveBps(false);
      }
    });
    _controller03.value =
        ref.watch(utilsProvider.select((connection) => connection.liveBps!));
  }
}
