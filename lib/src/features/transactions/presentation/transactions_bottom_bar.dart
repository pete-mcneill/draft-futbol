import 'package:flutter/material.dart';

class TransactionsBottomBar extends StatefulWidget {
  final Function(int index) updateIndex;
  final int currentIndex;
  const TransactionsBottomBar(
      {Key? key,
      required this.updateIndex,
      required this.currentIndex})
      : super(key: key);

  @override
  _TransactionsBottomBarState createState() => _TransactionsBottomBarState();
}

class _TransactionsBottomBarState extends State<TransactionsBottomBar> {
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
      label: 'Waivers',
    ),
    NavigationDestination(
      icon: Icon(Icons.table_rows),
      label: 'Free Agents',
    ),
        NavigationDestination(
      icon: Icon(Icons.table_rows),
      label: 'Trades',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.currentIndex;
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
