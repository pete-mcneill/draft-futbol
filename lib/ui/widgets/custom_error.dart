import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  String? errorMessage;
  CustomError({Key? key, this.errorMessage = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
            child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headline2!,
          textAlign: TextAlign.center,
          child: Container(
              margin: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
              alignment: FractionalOffset.center,
              color: Theme.of(context).canvasColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text("An error occurred, please restart the app"),
                  ),
                  if (this.errorMessage!.isNotEmpty) Text(errorMessage!)
                ],
              )),
        )));
  }
}
