import 'package:draft_futbol/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class UiSettingsDialog extends ConsumerStatefulWidget {
  const UiSettingsDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UiSettingsDialogState();
}

class _UiSettingsDialogState extends ConsumerState<UiSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    bool remainingPlayers = ref.watch(
        utilsProvider.select((connection) => connection.remainingPlayersView!));
    bool iconSummary = ref.watch(
        utilsProvider.select((connection) => connection.iconSummaryView!));
    return Dialog(
        child: SizedBox(
            height: 300.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: ListView(
              children: [
                const Center(
                  child: Text("UI Settings"),
                ),
                SwitchListTile(
                  title: const Text(
                    'Remaining Players',
                  ),
                  subtitle: const Text(
                      "View Remaining players on preview for H2H matches"),
                  value: remainingPlayers,
                  onChanged: (bool value) {
                    ref
                        .read(utilsProvider.notifier)
                        .setRemainingPlayersView(value);
                    Hive.box("settings").put("remainingPlayersView", value);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    'Icons Summary',
                  ),
                  subtitle: const Text(
                      "Summary of teams contributions in GW via Icons"),
                  value: iconSummary,
                  onChanged: (bool value) {
                    ref.watch(utilsProvider.notifier).setIconSummaryView(value);
                    Hive.box("settings").put("iconSummaryView", value);
                    setState(() {});
                  },
                )
              ],
            )));
  }
}
