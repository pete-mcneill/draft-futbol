import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/ui/widgets/ui_settings_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftAppBar extends ConsumerStatefulWidget with PreferredSizeWidget {
  DraftAppBar({Key? key}) : super(key: key);

  @override
  _DraftAppBarState createState() => _DraftAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DraftAppBarState extends ConsumerState<DraftAppBar> {
  List<DropdownMenuItem<String>> menuOptions = [];
  late String dropdownValue;
  final List<bool> _isSelected = [false, true];
  bool showBpsButton = true;
  final _controller03 = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller03.addListener(() {
      if (_controller03.value) {
        ref.watch(utilsProvider.notifier).updateLiveBps(true);
      } else {
        ref.watch(utilsProvider.notifier).updateLiveBps(false);
      }
    });
    menuOptions = [];
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
    _controller03.value =
        ref.watch(utilsProvider.select((connection) => connection.liveBps!));
    showBpsButton = ref
        .watch(utilsProvider.select((connection) => connection.showBpsButton!));
    return AppBar(
      elevation: 0,
      title: DropdownButtonHideUnderline(
        child: DropdownButton2(
          iconEnabledColor: Theme.of(context).secondaryHeaderColor,
          isExpanded: true,
          // customItemsIndexes: const [3],
          // customItemsHeight: 8,
          items: menuOptions,
          onChanged: (value) {
            ref
                .read(utilsProvider.notifier)
                .updateActiveLeague(value.toString());
          },
          value: dropdownValue,
          // itemHeight: 48,
          // itemPadding: const EdgeInsets.only(left: 16, right: 16),
          // dropdownWidth: 180,
          // dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
          dropdownDecoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).appBarTheme.backgroundColor),
          // dropdownElevation: 8,
          // offset: const Offset(0, 8),
        ),
      ),

      // DropdownButton<String>(
      //   dropdownColor: Theme.of(context).canvasColor,
      //   focusColor: Theme.of(context).highlightColor,

      //   value: dropdownValue,
      //   // icon: const Icon(Icons.arrow_downward),
      //   elevation: 20,
      //   style: const TextStyle(color: Colors.white),
      //   underline: Container(
      //     height: 0,
      //   ),
      //   onChanged: (String? newValue) {
      //     // setState(() {
      //     //   dropdownValue = newValue!;
      //     // });
      //     Provider.of<UtilsProvider>(context, listen: false)
      //         .updateActiveLeague(newValue!);
      //   },
      //   items: menuOptions,
      // ),

      // Text("GW ${gameweek.currentGameweek.toString()}"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            showBpsButton
                ? AdvancedSwitch(
                    activeChild: const Text('BPS'),
                    inactiveChild: const Text('BPS'),
                    width: 56,
                    height: 28,
                    controller: _controller03,
                    activeColor:
                        Theme.of(context).buttonTheme.colorScheme!.secondary,
                  )
                // inactiveColor: Theme.of(context).cardColor)
                : const SizedBox(),
            IconButton(
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
            ),
          ],
        ),
        // Icon(Icons.search),
      ],
    );
  }
}
