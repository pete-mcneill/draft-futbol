import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<Widget> getBannerWidget(
    {required BuildContext context,
    required AdSize adSize,
    required bool noAdverts}) async {
  if (noAdverts) {
    return const SizedBox();
  } else {
    BannerAd bannerAd = BannerAd(
      // Test ID
      adUnitId: Platform.isAndroid
          ? "ca-app-pub-3940256099942544/6300978111"
          : "ca-app-pub-3940256099942544/2934735716",
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          print("Loading banner");
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print("onAdFailedToLoad: $error");
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {
          print("OPENING BANNER AD");
        },
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an ad is in the process of leaving the application.
      ),
    );

    await bannerAd.load();

    return Container(
      child: AdWidget(ad: bannerAd),
      constraints: BoxConstraints(
        maxHeight: 100,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: 32,
        minWidth: MediaQuery.of(context).size.width,
      ),
    );
  }
}

String getInterstitialAdUnitIds() {
  // Test ID
  if (Platform.isAndroid) {
    return "ca-app-pub-3940256099942544/1033173712";
  } else {
    return "ca-app-pub-3940256099942544/4411468910";
  }
}
