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
      content: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            color: Colors.white60,
            fontSize: 18.0,
          ),
          children: <TextSpan>[
            TextSpan(
                text:
                    'Cup has been saved successfully. You can now view fixtures from the Cup section in the More tab. \n A new Tab with live Cup Scores will automatically appear on a Cup Gameweek.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
