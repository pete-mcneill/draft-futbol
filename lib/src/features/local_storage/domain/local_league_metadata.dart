import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'local_league_metadata.g.dart';

@HiveType(typeId: 0)
class LocalLeagueMetadata {
  LocalLeagueMetadata({required this.id, required this.name, required this.scoring, required this.adminId});

  factory LocalLeagueMetadata.create(var leagueData) {
    return LocalLeagueMetadata(id: leagueData['id'], name: leagueData['name'], scoring: leagueData['scoring'], adminId: leagueData['admin_entry']);
  }

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String scoring;
  @HiveField(3)
  final int adminId;
}