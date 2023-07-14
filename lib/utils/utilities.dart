// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class UtilitiesProvider extends StateNotifier<Utilities> {
  UtilitiesProvider() : super(Utilities());

  void setLeagueIds(Map<String, dynamic> leagueIds) {
    state = state.copyWith(leagueIds: leagueIds);
  }

  void updateLiveBps(bool value) {
    Future.delayed(Duration.zero, () async {
      state = state.copyWith(liveBps: value);
    });
  }

  void showBpsButton(bool value) {
    state = state.copyWith(showBpsButton: value);
  }

  void updateActiveLeague(String value) {
    state = state.copyWith(activeLeagueId: value);
  }

  void setDefaultActiveLeague() {
    for (String key in state.leagueIds!.keys) {
      if (state.activeLeagueId!.isEmpty) {
        state = state.copyWith(activeLeagueId: key);
        break;
      }
    }
    if (state.leagueIds!.isEmpty) {
      state = state.copyWith(activeLeagueId: "");
    }
  }

  void updateIsLightTheme(bool value) {
    state = state.copyWith(isLightTheme: value);
  }

  void updateSubscriptionPrice(String value) {
    state = state.copyWith(subscriptionPrice: value);
  }

  void setRemainingPlayersView(bool value) {
    state = state.copyWith(remainingPlayersView: value);
  }

  void setIconSummaryView(bool value) {
    state = state.copyWith(iconSummaryView: value);
  }

  void setSubModeEnabled(bool value){
    state = state.copyWith(subModeEnabled: value);
  }

    void setSubsReset(bool value){
    state = state.copyWith(subsReset: value);
  }
}

class Utilities {
  bool? iconSummaryView = false;
  bool? remainingPlayersView = false;
  Map<String, dynamic>? leagueIds = {};
  String? activeLeagueId;
  bool? noAdverts = false;
  bool? liveBps = false;
  bool? showBpsButton = true;
  bool? isLightTheme = true;
  String? subscriptionPrice = "";
  bool? subModeEnabled = false;
  bool? subsReset = false;
  Utilities(
      {this.activeLeagueId = "",
      this.noAdverts = false,
      this.liveBps = false,
      this.showBpsButton = true,
      this.leagueIds,
      this.isLightTheme = true,
      this.subscriptionPrice = "",
      this.remainingPlayersView = false,
      this.iconSummaryView = false,
      this.subModeEnabled = false,
      this.subsReset = false});

  void setLiveBps(bool bps) {
    liveBps = bps;
  }

  Utilities copyWith(
      {String? activeLeagueId,
      bool? noAdverts,
      bool? liveBps,
      bool? showBpsButton,
      Map<String, dynamic>? leagueIds,
      bool? isLightTheme,
      String? subscriptionPrice,
      bool? remainingPlayersView,
      bool? iconSummaryView,
      bool? subModeEnabled,
      bool? subsReset}) {
    return Utilities(
        activeLeagueId: activeLeagueId ?? this.activeLeagueId,
        noAdverts: noAdverts ?? this.noAdverts,
        liveBps: liveBps ?? this.liveBps,
        showBpsButton: showBpsButton ?? this.showBpsButton,
        leagueIds: leagueIds ?? this.leagueIds,
        isLightTheme: isLightTheme ?? this.isLightTheme,
        subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
        remainingPlayersView: remainingPlayersView ?? this.remainingPlayersView,
        iconSummaryView: iconSummaryView ?? this.iconSummaryView,
        subModeEnabled: subModeEnabled ?? this.subModeEnabled,
        subsReset: subsReset ?? this.subsReset);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'activeLeagueId': activeLeagueId,
      'noAdverts': noAdverts,
      'liveBps': liveBps,
      'showBpsButton': showBpsButton,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Utilities(activeLeagueId: $activeLeagueId, noAdverts: $noAdverts, liveBps: $liveBps, showBpsButton: $showBpsButton)';
  }

  @override
  bool operator ==(covariant Utilities other) {
    if (identical(this, other)) return true;

    return other.activeLeagueId == activeLeagueId &&
        other.noAdverts == noAdverts &&
        other.liveBps == liveBps &&
        other.showBpsButton == showBpsButton;
  }

  @override
  int get hashCode {
    return activeLeagueId.hashCode ^
        noAdverts.hashCode ^
        liveBps.hashCode ^
        showBpsButton.hashCode;
  }
}
