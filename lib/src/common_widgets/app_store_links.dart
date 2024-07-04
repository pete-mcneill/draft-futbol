import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<Widget> appStoreLinks() => [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              var url = Uri.parse('https://apps.apple.com/app/id${1531072237}');
              launchUrl(url);
            },
            child: Center(
                child: Image.asset(
              "assets/images/app_store.png",
              height: 100,
              width: 100,
            )),
          ),
          GestureDetector(
            onTap: () {
              var url = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.psjmcneill.draftfutbol&pli=1');
              launchUrl(url);
            },
            child: Center(
                child: Image.asset(
              "assets/images/play_store.png",
              height: 100,
              width: 100,
            )),
          ),
        ],
      ),
    ];
