import 'dart:convert';

import 'package:draft_futbol/providers/providers.dart';
import 'package:draft_futbol/services/api_service.dart';
import 'package:draft_futbol/ui/screens/initialise_home_screen.dart';
import 'package:draft_futbol/ui/widgets/coffee.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  final textFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final introKey = GlobalKey<IntroductionScreenState>();

  late String leagueName;
  late int leagueId;
  late String leagueType;
  bool leagueSet = false;
  bool leagueError = false;
  late String leagueErrorMessage;

  void _onIntroEnd(context) async {
    if (_formKey.currentState!.validate() && leagueSet) {
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      Map<String, dynamic>? leagueMap;
      // _prefs.clear();
      String? leagueIds;
      try {
        leagueIds = _prefs.getString('league_ids');
        leagueMap = json.decode(leagueIds!);
        leagueMap![leagueId.toString()] = {
          "name": leagueName,
          "season": "23/24"
        };
      } catch (e) {
        leagueMap = {
          leagueId.toString(): {"name": leagueName, "season": "23/24"}
        };
      }
      await _prefs.setString('league_ids', jsonEncode(leagueMap));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const InitialiseHomeScreen()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Api _api = Api();
    return Container(
      child: SafeArea(
        child: IntroductionScreen(
          key: introKey,
          showSkipButton: true,
          skip: const Text("Know your league ID?"),
          pages: [
            PageViewModel(
              title: "Welcome to Draft Futbol",
              image: const Center(
                  child: Image(
                      image: AssetImage('assets/images/app_icon.png'),
                      height: 200,
                      width: 200)),
              decoration: PageDecoration(
                pageColor: Theme.of(context).cardColor,
              ),
              // titleTextStyle: const TextStyle(
              //     color: Color(0xffFFB302), fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // const Image(image: AssetImage('assets/images/logo.png')),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                      children: const <TextSpan>[
                        TextSpan(
                          text:
                              "\n \n This app will help you keep track of live scores in your FPL Draft Leagues",
                        ),
                        TextSpan(
                          text:
                              "\n Over the next few pages we will link this app to your FPL league for future use.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PageViewModel(
              title: "Note from the developer!",
              decoration: const PageDecoration(
                  titleTextStyle: TextStyle(fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text:
                              "\n I develop this app in my spare time, primarily for my own draft league but wanted to share it with the community",
                        ),
                        const TextSpan(
                          text:
                              "\n \n If you like or get good use of the app, any donations to keep it on the app store would be appreciated!",
                        ),
                        const TextSpan(
                          text: '\n \n Thanks for downloading!',
                        ),
                      ],
                    ),
                  ),
                  buyaCoffeebutton(context),
                  const SizedBox(
                    height: 20,
                  ),
                  const Image(
                    image: AssetImage('assets/images/1024_1024-icon.png'),
                    height: 100,
                    width: 100,
                  ),
                ],
              ),
            ),
            PageViewModel(
              title: "League Setup",
              decoration: PageDecoration(
                  pageColor: Theme.of(context).colorScheme.background,
                  titleTextStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                      children: const <TextSpan>[
                        TextSpan(
                          text:
                              "\n There are a number of ways to get your League ID",
                        ),
                        TextSpan(
                          text:
                              "\n \n If the season has not started, your league admin can access the edit league page. \n The number in the url for this page will contain your league ID. \n For example :",
                        ),
                        TextSpan(
                            text:
                                ' \n https://draft.premierleague.com/league/48/edit \n',
                            style: TextStyle(color: Colors.blue)),
                        TextSpan(
                          text: '\n 48 being the league ID',
                        ),
                        TextSpan(
                          text:
                              '\n \n If the league has started. Navigate to the Points page to view your team for the current Gameweek. \n The league ID will be in the url.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PageViewModel(
              title: "League Setup",
              decoration: PageDecoration(
                  pageColor: Theme.of(context).colorScheme.background,
                  titleTextStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                      children: <TextSpan>[
                        const TextSpan(
                          text:
                              "\n \n If you are unable to find your League ID using the previous ways.",
                        ),
                        const TextSpan(
                          text:
                              "\n Ensure you are already logged onto the FPL website, then open the following link:",
                        ),
                        TextSpan(
                          text:
                              '\n https://draft.premierleague.com/api/bootstrap-dynamic',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launch(
                                  'https://draft.premierleague.com/api/bootstrap-dynamic',
                                  forceWebView: false,
                                  forceSafariVC: false);
                            },
                        ),
                        const TextSpan(
                          text:
                              '\n \n On this page look for a section called "leagues", it will contain your league name but also the ID of your league. Make note of this ID',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Image(image: AssetImage('assets/images/league.png')),
                ],
              ),
            ),
            PageViewModel(
              title: "League Setup",
              decoration: PageDecoration(
                  pageColor: Theme.of(context).colorScheme.background,
                  titleTextStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      // style: TextStyle(color: Color(0xffFFB302)),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n \n  Insert your League ID below:',
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: textFieldController,
                      textAlign: TextAlign.center,
                      // cursorColor: Color(0xffFFB302),
                      style: const TextStyle(
                          // color: Color(0xffFFB302),
                          fontWeight: FontWeight.bold),
                      validator: (text) {
                        if (text!.isEmpty) {
                          return 'Please enter your league ID';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                          hintStyle: TextStyle(
                              // color: Color(0xffFFB302).withOpacity(0.5)
                              ),
                          // fillColor: Color(0xffFFB302),
                          border: InputBorder.none,
                          hintText: '12345'),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _api
                            .checkLeagueExists(textFieldController.text)
                            .then((value) => {
                                  if (value['valid'])
                                    {
                                      leagueSet = true,
                                      leagueName = value['name'],
                                      leagueType = value['type'],
                                      setState(() {
                                        leagueSet = true;
                                        leagueName = leagueName;
                                        leagueError = false;
                                        leagueId =
                                            int.parse(textFieldController.text);
                                        leagueType = leagueType;
                                      }),
                                    }
                                  else
                                    {
                                      setState(() {
                                        leagueSet = false;
                                        leagueError = true;
                                        leagueErrorMessage = value['reason'];
                                        leagueName = '';
                                      }),
                                    }
                                });
                        // On button presed
                      }
                    },
                    child: const Text("Search for league"),
                  ),
                  const SizedBox(height: 10),
                  leagueSet
                      ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "League Name: $leagueName",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const TextSpan(
                                text:
                                    "\n \n Please verify the league name is correct before continuing, this league will be saved for future use in the app.",
                              ),
                              const TextSpan(
                                text:
                                    "\n \n Additional leagues can be added or removed via settings in the app.",
                              )
                            ],
                          ),
                        )
                      : const SizedBox(),
                  leagueError
                      ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: leagueErrorMessage,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ],
          onDone: () => _onIntroEnd(context),
          //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
          // showSkipButton: false,

          // skipFlex: 0,
          nextFlex: 0,
          next: Icon(
            Icons.arrow_forward,
            color: Theme.of(context).buttonTheme.colorScheme!.secondary,
          ),
          done: Text('Done',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).buttonTheme.colorScheme!.secondary)),
          dotsDecorator: DotsDecorator(
            size: const Size(5.0, 5.0),
            color: Theme.of(context).buttonTheme.colorScheme!.secondary,
            activeColor: Theme.of(context).buttonTheme.colorScheme!.secondary,
            activeSize: const Size(22.0, 10.0),
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }
}
