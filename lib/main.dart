// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:soncore/nav_bar.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:soncore/now_playing.dart';
import 'package:soncore/routes/routes.dart';
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

int selected = 1;
int previous = 1;
// final emmpty = {'title': '', 'artist': '', 'id': 0};

// ignore: prefer_typing_uninitialized_variables
var nowplaying;

var album;

var barheight = 80.0;

// ignore: prefer_final_fields
var queue = ConcatenatingAudioSource(
  children: [],
);

double frac = 0;

final searchbar = TextEditingController();

var hasplayed = false;

var children = [];

var albums = [];

var fullsongs = [];

var icon = Icons.play_arrow;

Sorts? selectedMenu = Sorts.title;

Stream<PositionData> get positionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setState(() {});
    player.setAudioSource(queue);
    inititems();
    // if (!children.isNotEmpty) children.add(emmpty);
  }

  void inititems() async {
    super.initState();
    setState(() {});
    await _getitems();
  }

  void _sort() {
    String? value = selectedMenu.toString().split('.')[1];
    var temp = children;
    temp.sort(((a, b) => a[value]
        .toString()
        .toUpperCase()
        .compareTo(b[value].toString().toUpperCase())));
    setState(() {
      children = temp;
    });
  }

  Future<void> _getsongs() async {
    try {
      var res = await get(Uri.parse('http://kwak.sytes.net/v0/all'));

      var body = utf8.decode(res.bodyBytes);
      var data = jsonDecode(body) as List;

      setState(() {
        if (data.length != children.length) {
          children = data;
          fullsongs = data;
        }
      });
      _sort();
    } catch (err) {
      setState(() {
        children.clear();
        // children.add(emmpty);
      });
    }
  }

  void _sortAlbums() {
    var tem = albums;
    setState(() {
      albums = tem;
    });
  }

  Future<void> _getalbums() async {
    try {
      var res = await get(Uri.parse('http://kwak.sytes.net/v0/album/all'));

      var body = utf8.decode(res.bodyBytes);
      var data = jsonDecode(body) as List;
      var temp = [];
      for (var album in data) {
        if (album == null) continue;
        temp.add(album);
      }
      setState(() {
        if (temp.length != albums.length) {
          albums = temp;
        }
      });
      _sortAlbums();
    } catch (err) {
      setState(() {
        albums.clear();
        // children.add(emmpty);
      });
    }
  }

  Future<void> _getitems() async {
    if (selected == 1) {
      await _getsongs();
    } else if (selected == 2) {
      await _getalbums();
    }
  }

  // void _play(id) async {
  //   setState(() {
  //     nowplaying =
  //         children.firstWhere((element) => element['id'] == id, orElse: (() {
  //       return null;
  //     }));
  //     hasplayed = true;
  //     icon = Icons.pause;
  //   });
  //   await queue
  //       .add(AudioSource.uri(Uri.parse('http://kwak.sytes.net/tracks/$id'),
  //           tag: MediaItem(
  //             id: id.toString(),
  //             title: nowplaying['title'],
  //             artist: nowplaying['artist'],
  //             album: nowplaying['album'],
  //             artUri: Uri.parse('http://kwak.sytes.net/v0/cover/$id'),
  //           )));
  //   await player.seekToNext();
  //   player.play();
  // }

  Future<void> _play(id) async {
    if (children.length != queue.length) {
      queue.clear();
      for (var song in children) {
        await queue.add(AudioSource.uri(
            Uri.parse('http://kwak.sytes.net/tracks/${song['id']}'),
            tag: MediaItem(
              id: song['id'].toString(),
              title: song['title'],
              artist: song['artist'],
              album: song['album'],
              artUri: Uri.parse('http://kwak.sytes.net/v0/cover/${song['id']}'),
            )));
      }
    }
    setState(() {
      nowplaying =
          children.firstWhere((element) => element['id'] == id, orElse: (() {
        return null;
      }));
      var index = children.indexOf(nowplaying);
      player.seek(Duration.zero, index: index);
      player.play();
      hasplayed = true;
      icon = Icons.pause;
    });
  }

  void update() {
    setState(() {});
  }

  void _playpause() {
    setState(() {
      if (player.playing) {
        player.pause();
        icon = Icons.play_arrow;
      } else {
        player.play();
        icon = Icons.pause;
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
            .contains(query.toLowerCase());
      }).toList();
      // if (children.isEmpty) children.add(emmpty);
      // children.removeWhere((element) {
      // });
    });
  }

  void _raisefrac() {
    setState(() {
      frac = frac == 1 ? 0 : 1;
    });
  }

  Future<void> _gonext() async {
    // setState(() {
    //   var id = nowplaying['id'];
    //   var nexti = children.indexWhere((element) => element['id'] == id) + 1;
    //   nowplaying = children[nexti];
    //   _play(nowplaying['id']);
    // });
    await player.seekToNext();
    setState(() {
      nowplaying = children.firstWhere(
          (element) =>
              element['id'] ==
              int.parse(queue.sequence[player.currentIndex!].tag.id),
          orElse: (() {
        return null;
      }));
    });
  }

  Future<void> _goprevious() async {
    // setState(() {
    //   var id = nowplaying['id'];
    //   var nexti = children.indexWhere((element) => element['id'] == id) - 1;
    //   nowplaying = children[nexti];
    //   _play(nowplaying['id']);
    // });
    await player.seekToPrevious();
    setState(() {
      nowplaying = children.firstWhere(
          (element) =>
              element['id'] ==
              int.parse(queue.sequence[player.currentIndex!].tag.id),
          orElse: (() {
        return null;
      }));
    });
  }

  void _clear() {
    setState(() {
      searchbar.clear();
      children = fullsongs;
    });
  }

  void updatePage(int i) {
    setState(() {
      selected = i;
    });
  }

  void showplaying() {
    setState(() {
      previous = selected;
      selected = 4;
    });
  }

  // ignore: prefer_final_fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Routes(
              update: update,
              index: selected,
              showplaying: showplaying,
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
          Positioned(
            left: 15,
            bottom: 10,
            child: NowPlaying(
                positionDataStream: positionDataStream,
                gonext: _gonext,
                goprevious: _goprevious,
                icon: icon,
                playpause: _playpause,
                showplaying: showplaying),
          )
        ],
      ),
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
