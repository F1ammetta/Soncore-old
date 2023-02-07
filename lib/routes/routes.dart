import 'package:flutter/material.dart';
import 'package:soncore/main.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:soncore/main.dart';
import 'package:soncore/routes/albums.dart';
import 'package:soncore/routes/albumscreen.dart';
import 'package:soncore/routes/home.dart';
import 'package:soncore/routes/playlists.dart';
import 'package:soncore/routes/queue.dart';
import 'package:soncore/routes/songscreen.dart';
import 'package:soncore/routes/songs.dart';

// ignore: must_be_immutable
class Routes extends StatefulWidget {
  void Function() showplaying;
  void Function() inititems;
  void Function() sort;
  Future<void> Function() getitems;

  Future<void> Function(int) play;
  void Function(String) showqueries;
  void Function() raisefrac;
  void Function() playpause;
  Future<void> Function() gonext;
  Future<void> Function() goprevious;
  void Function() clear;
  void Function() update;
  int index;
  Routes(
      {super.key,
      required this.update,
      required this.index,
      required this.showplaying,
      required this.clear,
      required this.getitems,
      required this.gonext,
      required this.goprevious,
      required this.inititems,
      required this.play,
      required this.playpause,
      required this.raisefrac,
      required this.showqueries,
      required this.sort});
  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  List<Widget> routes = [];
  @override
  void initState() {
    super.initState();
    routes.add(const HomePage());
    routes.add(SongsPage(
        update: widget.update,
        showplaying: widget.showplaying,
        clear: widget.clear,
        getitems: widget.getitems,
        gonext: widget.gonext,
        goprevious: widget.goprevious,
        inititems: widget.inititems,
        play: widget.play,
        playpause: widget.playpause,
        raisefrac: widget.raisefrac,
        showqueries: widget.showqueries,
        sort: widget.sort));
    routes.add(AlbumsPage(
        showplaying: widget.showplaying,
        clear: widget.clear,
        getitems: widget.getitems,
        gonext: widget.gonext,
        goprevious: widget.goprevious,
        inititems: widget.inititems,
        play: widget.play,
        playpause: widget.playpause,
        raisefrac: widget.raisefrac,
        showqueries: widget.showqueries,
        sort: widget.sort,
        update: widget.update));
    routes.add(const PlaylistsPage());
    routes.add(PlayingScreen(
        update: widget.update,
        gonext: widget.gonext,
        goprevious: widget.goprevious,
        playpause: widget.playpause));
    routes.add(QueuePage(
      update: widget.update,
    ));
    routes.add(AlbumScreen(
        sort: widget.sort, play: widget.play, update: widget.update));
  }

  @override
  Widget build(BuildContext context) {
    return routes[widget.index];
  }
}
