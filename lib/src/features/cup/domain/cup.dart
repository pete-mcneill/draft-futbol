import 'package:draft_futbol/src/features/cup/domain/cup_fixture.dart';
import 'package:hive/hive.dart';

part 'cup.g.dart';

@HiveType(typeId: 3)
class Cup {
  @HiveField(0)
  String name;
  @HiveField(1)
  List<dynamic> rounds;
  @HiveField(2)
  Map<String, List<dynamic>> fixtures;
  @HiveField(3)
  List<int> teamIds;

  Cup(this.name, this.rounds, this.fixtures, this.teamIds);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rounds': rounds,
      'fixtures': fixtures,
      'teamIds': teamIds
    };
  }
}
