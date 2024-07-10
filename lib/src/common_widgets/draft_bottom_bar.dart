import 'package:flutter/material.dart';

class DraftBottomBar extends StatefulWidget {
  final Function(int index) updateIndex;
  final int currentIndex;
  final String leagueType;
  const DraftBottomBar(
      {Key? key,
      required this.updateIndex,
      required this.leagueType,
      required this.currentIndex})
      : super(key: key);

  @override
  _DraftBottomBarState createState() => _DraftBottomBarState();
}

class _DraftBottomBarState extends State<DraftBottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.updateIndex(index);
  }

  List<NavigationDestination> h2hOptions = const [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: 'Matches',
    ),
    NavigationDestination(
      icon: Icon(Icons.table_rows),
      label: 'Standings',
    ),
    NavigationDestination(
      icon: Icon(Icons.sports),
      label: 'PL Matches',
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz),
      label: 'More',
    ),
  ];

  List<NavigationDestination> classicOptions = [
    const NavigationDestination(
      icon: Icon(Icons.table_rows),
      label: 'Standings',
    ),
    const NavigationDestination(
      icon: Icon(Icons.sports),
      label: 'PL Matches',
    ),
    const NavigationDestination(
      icon: Icon(Icons.more_horiz),
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // _selectedIndex = widget.currentIndex;
    return NavigationBar(
      // backgroundColor: const Color(0xFF1a1c23),
      // selectedFontSize: 18,
      // unselectedFontSize: 14,
      // selectedIconTheme: IconThemeData(
      //     color: Theme.of(context).navigationBarTheme.indicatorColor),
      // unselectedIconTheme: IconThemeData(
      //     color: Theme.of(context).navigationBarTheme.backgroundColor),
      // selectedItemColor: Theme.of(context).navigationBarTheme.indicatorColor,
      // elevation: 50,
      destinations: h2hOptions,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
    );
  }
}
