// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  void Function(int) updatedPage;
  NavBar({super.key, required this.updatedPage});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (v) {
        setState(() {
          selected = v;
          widget.updatedPage(v);
        });
      },
      selectedIndex: selected,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      // ignore: prefer_const_literals_to_create_immutables
      destinations: [
        const NavigationDestination(
          icon: Icon(
            Icons.home,
          ),
          label: "Home",
        ),
        const NavigationDestination(
          icon: Icon(
            Icons.music_note,
          ),
          label: "Songs",
        ),
        const NavigationDestination(
          icon: Icon(
            Icons.album,
          ),
          label: "Albums",
        ),
        const NavigationDestination(
          icon: Icon(
            Icons.queue_music,
          ),
          label: "Playlists",
        ),
      ],
    );
  }
}
