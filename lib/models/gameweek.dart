class Gameweek {
  int currentGameweek;
  bool gameweekFinished;
  bool waiversProcessed;

  Gameweek(this.currentGameweek, this.gameweekFinished, this.waiversProcessed);

  factory Gameweek.fromJson(Map<String, dynamic> json) {
    int currentEvent = json['current_event'] ?? 0;
    return Gameweek(currentEvent, json['current_event_finished'],
        json['waivers_processed']);
  }
}
