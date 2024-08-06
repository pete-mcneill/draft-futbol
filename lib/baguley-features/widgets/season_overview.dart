import 'package:flutter/material.dart';

class BaguleySeasonOverview extends StatefulWidget {
  String season;
  String champion;
  String chairLeg;
  String? samGranger;
  BaguleySeasonOverview(
      {Key? key,
      required this.season,
      required this.champion,
      required this.chairLeg,
      this.samGranger})
      : super(key: key);

  @override
  State<BaguleySeasonOverview> createState() => _BaguleySeasonOverviewState();
}

class _BaguleySeasonOverviewState extends State<BaguleySeasonOverview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expanded(
        //   child:
        Container(
          color: Theme.of(context).cardColor,
          height: 150,
          
          child: ListView(
            shrinkWrap: true,
            // This next line does the trick.
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              SizedBox(
                width: 100,
                child: Card(
                  elevation: 8.0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                  child: ListTile(
                      tileColor: Theme.of(context).cardColor,
                      title: Text(
                          widget.season,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      // ),
                      subtitle: const Text("Tap for more info", style: TextStyle(color: Colors.white)),
                          ),
                ),
              ),
              Card(
                elevation: 8.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor,),
                    child: Column(
                      children: [
                        const Text("Baguley"),
                        Image.asset(
                          "assets/images/baguleyTrophy.png",
                          height: 75,
                        ),
                        Text(widget.champion)
                      ],
                    )),
              ),
              if(widget.samGranger != null) Card(
                elevation: 8.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor,),
                    child: Column(
                      children: [
                        const Text("Sam Granger"),
                        Image.asset(
                          "assets/images/samGranger.png",
                          height: 75,
                        ),
                        Text(widget.champion)
                      ],
                    )),
              ),
              Card(
                elevation: 8.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
                child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration:
                        BoxDecoration(color: Theme.of(context).cardColor,),
                    child: Column(
                      children: [
                        const Text("Chair Leg"),
                        Image.asset(
                          "assets/images/chairLeg.png",
                          height: 75,
                        ),
                        Text(widget.chairLeg)
                      ],
                    )),
              ),
            ],
          ),
        ),
        // ),
      ],
    );

    // Container(
    //   margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
    //   padding: const EdgeInsets.only(top:20.0, bottom: 20.0),
    //   decoration: BoxDecoration(
    //     border: Border.all(color: Colors.blueAccent),
    //     borderRadius: const BorderRadius.all(
    //         Radius.circular(8.0) //                 <--- border radius here
    //         ),
    //   ),
    //   child: Column(children: [
    //     Row(
    //       children: [
    //         Expanded(
    //           flex: 1,
    //           child: Column(
    //             children: [Text(widget.season, style: TextStyle(fontWeight: FontWeight.bold)),
    //             const Text("Tap for more info", textAlign: TextAlign.center, style: TextStyle(fontSize: 10,))],
    //           ),
    //         ),
    //         Expanded(
    //           flex: 2,
    //           child: Column(
    //             children: [
    //               const Icon(
    //                 Icons.favorite,
    //                 color: Colors.pink,
    //                 size: 12.0,
    //                 semanticLabel: 'Text to announce in accessibility modes',
    //               ),
    //               const Text("Champion"),
    //               Text(widget.champion),
    //               // if(widget.samGranger != null) Text("Sam Granger: " + widget.samGranger!)
    //             ],
    //           ),
    //         ),
    //                     Expanded(
    //           flex: 2,
    //           child: Column(
    //             children: [
    //               const Icon(
    //                 Icons.favorite,
    //                 color: Colors.pink,
    //                 size: 12.0,
    //                 semanticLabel: 'Text to announce in accessibility modes',
    //               ),
    //               const Text("Chair Leg"),
    //               Text(widget.chairLeg),
    //               // if(widget.samGranger != null) Text("Sam Granger: " + widget.samGranger!)
    //             ],
    //           ),
    //         ),
    //                     Expanded(
    //           flex: 2,
    //           child: Column(
    //             children: [
    //               const Icon(
    //                 Icons.favorite,
    //                 color: Colors.pink,
    //                 size: 12.0,
    //                 semanticLabel: 'Text to announce in accessibility modes',
    //               ),
    //               const Text("Sam Granger"),
    //               // Text(widget.samGranger!),
    //               // if(widget.samGranger != null) Text("Sam Granger: " + widget.samGranger!)
    //             ],
    //           ),
    //         ),
    //       ],
    //     )
    //   ]),
    // );
  }
}
