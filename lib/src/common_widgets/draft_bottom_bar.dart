import 'package:flutter/material.dart';

class DraftBottomBar extends StatefulWidget {
  final Function(int index) updateIndex;
  final int currentIndex;
  final bool cupGameweek;
  const DraftBottomBar(
      {Key? key,
      required this.updateIndex,
      required this.currentIndex,
      required this.cupGameweek})
      : super(key: key);

  @override
  _DraftBottomBarState createState() => _DraftBottomBarState();
}

class _DraftBottomBarState extends State<DraftBottomBar> {
  int _selectedIndex = 0;
  bool cupGameweek = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.updateIndex(index);
  }

  List<NavigationDestination> getH2hOptions() {
    return [
      const NavigationDestination(
        icon: Icon(Icons.schedule),
        label: 'Matches',
      ),
      const NavigationDestination(
        icon: Icon(Icons.table_rows),
        label: 'Standings',
      ),
      if (widget.cupGameweek)
        const NavigationDestination(
          icon: Icon(Icons.emoji_events),
          label: 'Cups',
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
  }

  @override
  Widget build(BuildContext context) {
    cupGameweek = widget.cupGameweek;
    return NavigationBar(
      destinations: getH2hOptions(),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
    );
  }
}
