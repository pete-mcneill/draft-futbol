import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:draft_futbol/src/features/cup/presentation/cup_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class DeleteCupDialog extends ConsumerWidget {
  final Cup cup;

  DeleteCupDialog({required this.cup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(
        "Delete ${cup.name}?",
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Confirm'),
          onPressed: () async {
            ref.read(cupDataControllerProvider.notifier).deleteCup(cup);
            await Hive.box('cups').delete(cup.name);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
