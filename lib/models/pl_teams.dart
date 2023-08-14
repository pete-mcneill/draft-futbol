import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlTeamsNotifier extends StateNotifier<PlTeams> {
  PlTeamsNotifier() : super(PlTeams());

  void addPlTeams(PlTeam team) {
    state.plTeams.addAll({team.id!: team});
  }
}

class PlTeams {
  Map<int, PlTeam> plTeams = {};

  PlTeams() : super();
}

class PlTeam {
  int? id;
  String? code;
  String? name;
  String? shortName;

  PlTeam({this.id, this.code, this.name, this.shortName});

  factory PlTeam.fromJson(var json) {
    return PlTeam(
        id: json['id'],
        code: json['code'].toString(),
        name: json['name'],
        shortName: json['short_name']);
  }
}
