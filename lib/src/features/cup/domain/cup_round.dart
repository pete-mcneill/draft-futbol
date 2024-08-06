class CupRound {
  String id;
  int gameweek;
  bool multipleLegs;
  int? secondGameweek;

  CupRound(this.id, this.gameweek, this.multipleLegs, this.secondGameweek);

  Map<String, dynamic> toJson() {
    return {
      'gameweek': gameweek,
      'multipleLegs': multipleLegs,
      'secondGameweek': secondGameweek,
    };
  }
}
