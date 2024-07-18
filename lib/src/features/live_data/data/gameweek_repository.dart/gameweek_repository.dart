
import 'package:draft_futbol/src/features/live_data/domain/gameweek.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gameweek_repository.g.dart';

class GameweekRepository {
  GameweekRepository();

  /// A map of all the orders placed by each user, where:
  /// - key: user ID
  /// - value: list of orders for that user
  final Gameweek gameweek = Gameweek(0, true, true);

  /// A stream that returns all the orders for a given user, ordered by date
  /// Only user orders that match the given productId will be returned.
  /// If a productId is not passed, all user orders will be returned.
  // Stream<List<Order>> watchUserOrders(String uid, {ProductID? productId}) {
  //   return _orders.stream.map((ordersData) {
  //     final ordersList = ordersData[uid] ?? [];
  //     ordersList.sort(
  //       (lhs, rhs) => rhs.orderDate.compareTo(lhs.orderDate),
  //     );
  //     if (productId != null) {
  //       return ordersList
  //           .where((order) => order.items.keys.contains(productId))
  //           .toList();
  //     } else {
  //       return ordersList;
  //     }
  //   });
  // }

  void setCurrentGameweek(var gameweek) {
    this.gameweek.currentGameweek = gameweek['currentGameweek'];
    this.gameweek.gameweekFinished =    gameweek['gameweekFinished'];
    this.gameweek.waiversProcessed =   gameweek['waiversProcessed'];
  }
}

@Riverpod(keepAlive: true)
GameweekRepository gameweekRepository(GameweekRepositoryRef ref) {
  return GameweekRepository();
}