import 'package:flutter/material.dart';

class ShameCorridor extends StatefulWidget {
  ShameCorridor({Key? key}) : super(key: key);

  @override
  State<ShameCorridor> createState() => _ShameCorridorState();
}

class _ShameCorridorState extends State<ShameCorridor> {
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
      child: Column(children:[
        Row(children: [
          Text("Shame Corridor", style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10))
        ],),
        Row(
          children: [
            Column(children: [
              Text("Loser1"),
              Row(children: [
                   const Icon(
                    Icons.one_k,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],),
              Row(children: [
                   const Icon(
                    Icons.heart_broken,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],)
            
                
            ],),
            Column(children: [
              Text("Loser2"),
              Row(children: [
                   const Icon(
                    Icons.one_k,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],),
              Row(children: [
                   const Icon(
                    Icons.heart_broken,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],)
            
                
            ],),
                        Column(children: [
              Text("Loser3"),
              Row(children: [
                   const Icon(
                    Icons.one_k,
                    color: Colors.pink,
                    size: 16.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text("x1")
              ],),
              Row(children: [
                   const Icon(
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
