import 'package:draft_futbol/models/draft_player.dart';
import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/subs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SubsInfoDiscoveryPopUp {
  static showAlertDialog(BuildContext context) async {
    Widget resetAll = ElevatedButton(
      child: Text("Ok"),
      onPressed: () {
        Hive.box('discovery').put("subDiscoveryInfo", true);
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "How to make subs",
        textAlign: TextAlign.center,
      ),
      content: Wrap(children: [
        Column(children: [
          Text(
            "Subs will update live scores in this app (FPL will not be impacted)",
            textAlign: TextAlign.center,
          ),
          Text(
            "Long press on a player on the bench and drag them to an eligible starter to swap.",
            textAlign: TextAlign.center,
          ),
          Text(
            "Eligible players to be swapped will be highlighted in green, ineligible in red",
            textAlign: TextAlign.center,
          ),
          Text(
            "Select save to keep subs, subs can also be reset",
            textAlign: TextAlign.center,
          ),
          Text(
            "This feature is still being development, any feedback or issues appreciated",
            textAlign: TextAlign.center,
          ),
        ]),
      ]),
      actions: [
        resetAll,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
