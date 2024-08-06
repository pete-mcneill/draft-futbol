import 'package:flutter/material.dart';

class HallOfFameQuickView extends StatefulWidget {
  const HallOfFameQuickView({Key? key}) : super(key: key);

  @override
  State<HallOfFameQuickView> createState() => _HallOfFameQuickViewState();
}

class _HallOfFameQuickViewState extends State<HallOfFameQuickView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      // padding: const EdgeInsets.only(top:20.0, bottom: 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: const BorderRadius.all(
            Radius.circular(8.0) //                 <--- border radius here
            ),
      ),
      child: const Column(children:[
        Row(children: [
          Text("Hall of Fame", style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10))
        ],),
        Row(
          children: [
            Column(children: [
              Text("Champ1"),
              Row(children: [
                   Icon(
                    Icons.one_k,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],),
              Row(children: [
                   Icon(
                    Icons.heart_broken,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],)
            
                
            ],),
            Column(children: [
              Text("Champ1"),
              Row(children: [
                   Icon(
                    Icons.one_k,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],),
              Row(children: [
                   Icon(
                    Icons.heart_broken,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],)
            
                
            ],),
                        Column(children: [
              Text("Champ1"),
              Row(children: [
                   Icon(
                    Icons.one_k,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],),
              Row(children: [
                   Icon(
                    Icons.heart_broken,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],)
            
                
            ],),
          ],
        )
      ]),
    );
  }
}
