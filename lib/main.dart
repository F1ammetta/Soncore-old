// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:http/http.dart';
import 'package:soncore/nav_bar.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:soncore/routes/routes.dart';
import 'package:soncore/routes/songs.dart';
import 'package:just_audio_background/just_audio_background.dart';

// ignore: unused_element

final player = AudioPlayer();
Color brandColor = Color(0XFF3BDFEB);

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(Root());
}

class PositionData {
  PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

enum Sorts { title, artist }

void _showplaying() {}

class _MyAppState extends State<MyApp> {
  int selected = 1;
  final emmpty = {'title': '', 'artist': ''};

  // ignore: prefer_typing_uninitialized_variables
  var _nowplaying;

  // ignore: prefer_final_fields
  var _queue = ConcatenatingAudioSource(
    children: [],
  );

  double _frac = 0;

  final _searchbar = TextEditingController();

  var _hasplayed = false;

  var children = [];

  var fullsongs = [];

  var _icon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    player.setAudioSource(_queue);
    inititems();
    if (!children.isNotEmpty) children.add(emmpty);
  }

  void inititems() async {
    await _getitems();
  }

  void _sort() {
    String? value = selectedMenu.toString().split('.')[1];
    var temp = children;
    temp.sort(((a, b) => a[value].compareTo(b[value])));
    setState(() {
      children = temp;
    });
  }

  Future<void> _getitems() async {
    try {
      var res = await get(Uri.parse('http://kwak.sytes.net/v0/all'));
      var data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      var temp = [];
      for (var song in data) {
        temp.add(song);
      }

      setState(() {
        if (temp.length != children.length) {
          children = temp;
          fullsongs = temp;
        }
      });
      _sort();
      print(children.length);
    } catch (err) {
      setState(() {
        children.clear();
        children.add(emmpty);
      });
    }
  }

  void _play(id) async {
    setState(() {
      _nowplaying =
          children.firstWhere((element) => element['id'] == id, orElse: (() {
        return null;
      }));
      _hasplayed = true;
      _icon = Icons.pause;
    });
    await _queue.add(AudioSource.uri(
        Uri.parse('http://kwak.sytes.net/tracks/$id'),
        tag: MediaItem(
            id: id.toString(),
            title: _nowplaying['title'],
            artist: _nowplaying['artist'],
            album: _nowplaying['album'],
            artUri: Uri.parse('http://kwak.sytes.net/v0/cover/$id'))));
    await player.seekToNext();
    player.play();
  }

  void _playpause() {
    setState(() {
      if (player.playing) {
        player.pause();
        _icon = Icons.play_arrow;
      } else {
        player.play();
        _icon = Icons.pause;
      }
    });
  }

  void _showqueries(String query) {
    setState(() {
      if (query.isEmpty) {
        children = fullsongs;
        return;
      }
      children = List.castFrom(fullsongs);
      children = children.where((element) {
        return element[selectedMenu.toString().split('.')[1]]
            .toString()
            .toLowerCase()
            .startsWith(query.toLowerCase());
      }).toList();
      if (children.isEmpty) children.add(emmpty);
      // children.removeWhere((element) {
      // });
    });
  }

  void _raisefrac() {
    setState(() {
      _frac = _frac == 1 ? 0 : 1;
    });
  }

  void _gonext() {
    setState(() {
      var id = _nowplaying['id'];
      var nexti = children.indexWhere((element) => element['id'] == id) + 1;
      _nowplaying = children[nexti];
      _play(_nowplaying['id']);
    });
  }

  void _goprevious() {
    setState(() {
      var id = _nowplaying['id'];
      var nexti = children.indexWhere((element) => element['id'] == id) - 1;
      _nowplaying = children[nexti];
      _play(_nowplaying['id']);
    });
  }

  void _clear() {
    setState(() {
      _searchbar.clear();
      children = fullsongs;
    });
  }

  void updatePage(int i) {
    setState(() {
      selected = i;
    });
  }

  Sorts? selectedMenu = Sorts.title;

  // ignore: prefer_final_fields

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Routes(
          index: selected,
          player: player,
          positionDataStream: _positionDataStream,
          selectedMenu: selectedMenu,
          showplaying: _showplaying,
          frac: _frac,
          children: children,
          emmpty: emmpty,
          hasplayed: _hasplayed,
          icon: _icon,
          nowplaying: _nowplaying,
          queue: _queue,
          searchbar: _searchbar,
          clear: _clear,
          getitems: _getitems,
          gonext: _gonext,
          goprevious: _goprevious,
          inititems: inititems,
          play: _play,
          playpause: _playpause,
          raisefrac: _raisefrac,
          showqueries: _showqueries,
          sort: _sort),
      bottomNavigationBar: NavBar(updatedPage: updatePage),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? dark) {
      ColorScheme lightColorScheme;
      ColorScheme darkColorScheme;

      if (lightDynamic != null && dark != null) {
        lightColorScheme = lightDynamic.harmonized()..copyWith();
        lightColorScheme = lightColorScheme.copyWith(secondary: brandColor);
        darkColorScheme = dark.harmonized();
      } else {
        lightColorScheme = ColorScheme.fromSeed(seedColor: brandColor);
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.dark,
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
        ),
        home: MyApp(),
      );
    });
  }
}
