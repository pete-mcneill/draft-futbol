import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
            child: DefaultTextStyle(
          style: Theme.of(context).textTheme.displayMedium!,
          textAlign: TextAlign.center,
          child: Container(
              margin: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              alignment: FractionalOffset.center,
              // color: Theme.of(context).canvasColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 10,
                      child: Center(
                          child: Image.asset(
                        "assets/images/logo2.png",
                        // height: 100,
                        // width: 100,
                      ))),
                  Expanded(
                    flex: 2,
                    child: Align(
                        alignment: FractionalOffset.topCenter,
                        child: SpinKitWaveSpinner(
                            color: Theme.of(context).colorScheme.secondary)),
                  )
                ],
              )),
        )));
  }
}
