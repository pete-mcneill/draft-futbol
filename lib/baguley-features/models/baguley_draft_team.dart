import 'package:draft_futbol/baguley-features/models/baguley_draft_player.dart';


class BaguleyDraftTeam {
  final int? entryId;
  final int? id;
  final String? teamName;
  final String? managerName;
  int? points;
  List<BaguleyDraftPlayer>? squad = [];

  BaguleyDraftTeam(
      {this.entryId,
      this.id,
      this.teamName,
      this.managerName,
      this.points,
      this.squad});

  bool checkIfValidSub(List<BaguleyDraftPlayer?> players, BaguleyDraftPlayer player, Map<String, List<BaguleyDraftPlayer>> squad){
    BaguleyDraftPlayer incomingSub = players[0]!;

    String outgoingPosition = player.position!;

    if(outgoingPosition == "FWD" && squad[outgoingPosition]!.length < 4 && player.playerName == "Ings"){
      return true;
    }

    return false;
  }

  factory BaguleyDraftTeam.fromJson(Map<String, dynamic> json) {
    String firstName = json['player_first_name'] ?? "";
    String secondName = json['player_last_name'] ?? "";
    return BaguleyDraftTeam(
        entryId: json['entry_id'] ?? 0,
        id: json['id'],
        teamName: json['entry_name'] ?? "Average",
        managerName: firstName + " " + secondName,
        squad: json['squad'],
        points: json['points']);
  }
}