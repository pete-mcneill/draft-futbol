import 'package:draft_futbol/models/players/stat.dart';

class PlMatchStats {
  int? matchId;
  List<Stat>? stats;

  PlMatchStats({this.matchId, this.stats});

  factory PlMatchStats.fromFirestoreData(Map<String, dynamic> json) {
    List<Stat> _stats = [];
    for (var stat in json['stats']) {
      Stat _stat = Stat.fromJson(stat);
      _stats.add(_stat);
    }
    return PlMatchStats(matchId: json["id"], stats: _stats);
  }

  factory PlMatchStats.fromJson(List<dynamic> json) {
    List<Stat> _stats = [];
    for (var stat in json[0]) {
      Stat _stat = Stat.fromJson(stat);
      _stats.add(_stat);
    }
    return PlMatchStats(matchId: json[1], stats: _stats);
  }
}
