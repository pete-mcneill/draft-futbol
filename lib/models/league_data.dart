class RawLeagueData {
  var standings;
  RawLeagueData({this.standings});

  factory RawLeagueData.from(RawLeagueData data) {
    return RawLeagueData(standings: data.standings);
  }
}
