import 'dart:convert';


/// Model class representing the shopping cart contents.
class AppSettings {
  AppSettings( {this.bonusPointsEnabled = false, this.activeLeagueId = 145});

  /// All the items in the shopping cart, where:
  /// - key: product ID
  /// - value: quantity
  bool bonusPointsEnabled;
  int activeLeagueId;

  Map<String, dynamic> toMap() {
    return {
      'bonusPointsEnabled': bonusPointsEnabled, 
      'activeLeagueId': activeLeagueId 
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      bonusPointsEnabled: map['bonusPointsEnabled'],
      activeLeagueId: map['activeLeagueId']
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) => AppSettings.fromMap(json.decode(source));

  @override
  String toString() => 'Cart(bonusPointsEnabled: $bonusPointsEnabled)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings && (other.bonusPointsEnabled == bonusPointsEnabled) && (other.activeLeagueId == activeLeagueId);
  }

  @override
  int get hashCode => activeLeagueId.hashCode;

  AppSettings copyWith({
    bool? bonusPointsEnabled,
    int? activeLeagueId,
  }) {
    return AppSettings(
      bonusPointsEnabled: bonusPointsEnabled ?? this.bonusPointsEnabled,
      activeLeagueId: activeLeagueId ?? this.activeLeagueId,
    );
  }
}