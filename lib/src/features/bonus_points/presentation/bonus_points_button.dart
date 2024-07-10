import 'dart:math';

import 'package:draft_futbol/src/features/bonus_points/presentation/bonus_points_controller.dart';
import 'package:draft_futbol/src/features/settings/data/settings_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

/// Shows a shopping cart item (or loading/error UI if needed)
class BonusPointsToggle extends ConsumerStatefulWidget {
  const BonusPointsToggle({Key? key,     this.animationDuration = const Duration(milliseconds: 400),
    this.height = 30,
    this.width = 100.0,
    this.borderRadius = 10.0,}) : super(key: key);
  final Duration animationDuration;
  final double height;
  final double width;
  final double borderRadius;
  @override
  _BonusPointsToggleState createState() => _BonusPointsToggleState();
}

class _BonusPointsToggleState extends ConsumerState<BonusPointsToggle> {
  bool selected = false;
  bool positive = false;
  double _animatedWidth = 0.0;
  Color green = Color(0xFF45CC0D);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    positive = ref.read(bonusPointsControllerProvider.notifier).liveBonusPointsState;
  }

  @override
  Widget build(BuildContext context) {
    // positive = ref.watch(appSettingsRepositoryProvider).bonusPointsEnabled;
    // bool test = ref.read(appSettingsRepositoryProvider).bonusPointsEnabled;
    // print(test);
return AnimatedToggleSwitch<bool>.dual(
                    current: positive,
                    first: false,
                    second: true,
                    spacing: 45.0,
                    animationDuration: const Duration(milliseconds: 600),
                    style: ToggleStyle(
                      borderColor: Colors.transparent,
                      indicatorColor: Colors.white,
                      backgroundColor: Colors.black,
                    ),
                    customStyleBuilder: (context, local, global) {
                      if (global.position <= 0.0)
                        return ToggleStyle(backgroundColor: Colors.red[800]);
                      return ToggleStyle(
                          backgroundGradient: LinearGradient(
                        colors: [green, Colors.red[800]!],
                        stops: [
                          global.position -
                              (1 - 2 * max(0, global.position - 0.5)) * 0.7,
                          global.position +
                              max(0, 2 * (global.position - 0.5)) * 0.7,
                        ],
                      ));
                    },
                    borderWidth: 6.0,
                    height: 30.0,
                    loadingIconBuilder: (context, global) =>
                        CupertinoActivityIndicator(
                            color: Color.lerp(
                                Colors.red[800], green, global.position)),
                    onChanged: (value) {
                          ref.read(bonusPointsControllerProvider.notifier).toggleLiveBonusPoints();
                          setState(() {
                            positive = value;
                          });
                        },
                    iconBuilder: (value) => value
                        ? Icon(Icons.done, color: green, size: 15.0)
                        : Icon(Icons.power_settings_new_rounded,
                            color: Colors.red[800], size: 15.0),
                    textBuilder: (value) => value
                        ? Center(child: Text('Live Bonus'))
                        : Center(child: Text('Live Bonus')),
                  );



// Stack(
//       children: [
//         Container(
//           height: widget.height,
//           width: widget.width,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(
//               widget.borderRadius,
//             ),
//             border: Border.all(
//               color: Colors.white,
//               width: 2.0
//             ),
//             color: Colors.transparent,
//           ),
//         ),
//         AnimatedContainer(
//           duration: widget.animationDuration,
//           height: widget.height,
//           width: _animatedWidth,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(
//               widget.borderRadius,
//             ),
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//         ),
//         InkWell(
//           child: Container(
//             height: widget.height,
//             width: widget.width,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(
//                 widget.borderRadius,
//               ),
//               color: Colors.transparent,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Live Bonus',
//                   style: TextStyle(
//                     color: selected ?Colors.white : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           onTap: () {
//             setState(() {
//               _animatedWidth = selected ? widget.width : 0.0;
//               selected = !selected;
//             });
//           },
//         ),
//       ],
//     );
  }
}