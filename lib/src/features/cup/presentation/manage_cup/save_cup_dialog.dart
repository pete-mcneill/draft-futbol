import 'package:draft_futbol/src/features/cup/domain/cup.dart';
import 'package:flutter/material.dart';

class SaveCupDialog extends StatelessWidget {
  final Cup cup;

  SaveCupDialog({required this.cup});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        cup.name,
      ),
      content: Text(
        cup.rounds.toString(),
      ),
    );
  }
}
