// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:soncore/main.dart';

class PlayingScreen extends StatefulWidget {
  Stream<PositionData> positionDataStream;
  dynamic nowplaying;
  IconData icon;
  void Function() goprevious;
  void Function() playpause;
  void Function() gonext;

  PlayingScreen(
      {super.key,
      required this.positionDataStream,
      required this.nowplaying,
      required this.icon,
      required this.gonext,
      required this.goprevious,
      required this.playpause});

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.network(
            'http://kwak.sytes.net/v0/cover/${widget.nowplaying['id']}',
            width: 300,
            height: 300,
          )
        ],
      ),
    );
  }
}
