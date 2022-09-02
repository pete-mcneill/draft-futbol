import 'package:flutter/material.dart';

class DraftBottomBar extends StatefulWidget {
  final Function(int index) updateIndex;
  final String leagueType;
  const DraftBottomBar(
      {Key? key, required this.updateIndex, required this.leagueType})
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

  List<BottomNavigationBarItem> h2hOptions = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.sports_soccer),
      label: 'Matches',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.table_rows),
      label: 'Standings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.sports),
      label: 'PL Matches',
    ),
  ];

  List<BottomNavigationBarItem> classicOptions = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.table_rows),
      label: 'Standings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.sports),
      label: 'PL Matches',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      items: widget.leagueType == 'h' ? h2hOptions : classicOptions,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
