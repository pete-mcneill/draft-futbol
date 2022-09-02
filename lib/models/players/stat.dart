class Stat {
  String? statName;
  int? fantasyPoints;
  int? value;

  Stat({this.statName, this.fantasyPoints, this.value});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
        statName: json['name'],
        fantasyPoints: json['points'],
        value: json['value']);
  }
}
