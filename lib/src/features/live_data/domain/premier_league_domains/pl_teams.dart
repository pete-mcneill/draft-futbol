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
