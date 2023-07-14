import 'package:draft_futbol/models/players/stat.dart';

class Match {
  int? matchId;
  List<Stat>? stats;

  Match({this.matchId, this.stats});

  factory Match.fromFirestoreData(Map<String, dynamic> json){

     List<Stat> _stats = [];
    for (var stat in json['stats']) {
      Stat _stat = Stat.fromJson(stat);
      _stats.add(_stat);
    }
    return Match(matchId: json["id"], stats: _stats);
  }

  factory Match.fromJson(List<dynamic> json) {
    List<Stat> _stats = [];
    for (var stat in json[0]) {
      Stat _stat = Stat.fromJson(stat);
      _stats.add(_stat);
    }
    return Match(matchId: json[1], stats: _stats);
  }
}
