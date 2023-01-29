import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:soncore/main.dart';

import '../now_playing.dart';

class SongsPage extends StatefulWidget {
  void Function() showplaying;
  void Function() inititems;
  void Function() sort;
  Future<void> Function() getitems;
  void Function(int) play;
  void Function() playpause;
  void Function(String) showqueries;
  void Function() raisefrac;
  void Function() gonext;
  void Function() goprevious;
  void Function() clear;

  SongsPage(
      {super.key,
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
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  _SongsPageState();
  // final emmpty = {'title': '', 'artist': ''};

  // // ignore: prefer_typing_uninitialized_variables
  // var _nowplaying;

  // // ignore: prefer_final_fields
  // var _queue = ConcatenatingAudioSource(
  //   children: [],
  // );

  // double _frac = 0;

  // final _searchbar = TextEditingController();

  // var _hasplayed = false;

  // var children = [];

  // var fullsongs = [];

  // var _icon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    player.setAudioSource(queue);
    widget.inititems();
    if (children.isNotEmpty) children.add(emmpty);
  }

  // void inititems() async {
  //   await _getitems();
  // }

  // void _sort() {
  //   String? value = widget.selectedMenu.toString().split('.')[1];
  //   var temp = children;
  //   temp.sort(((a, b) => a[value].compareTo(b[value])));
  //   setState(() {
  //     children = temp;
  //   });
  // }

  // Future<void> _getitems() async {
  //   try {
  //     var res = await get(Uri.parse('http://kwak.sytes.net/v0/all'));
  //     var data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
  //     var temp = [];
  //     for (var song in data) {
  //       temp.add(song);
  //     }
  //     setState(() {
  //       if (temp.length != children.length) {
  //         children = temp;
  //         fullsongs = temp;
  //       }
  //     });
  //     _sort();
  //   } catch (err) {
  //     children.clear();
  //     children.add(emmpty);
  //   }
  // }

  // void _play(id) async {
  //   setState(() {
  //     _nowplaying =
  //         children.firstWhere((element) => element['id'] == id, orElse: (() {
  //       return null;
  //     }));
  //     _hasplayed = true;
  //     _icon = Icons.pause;
  //   });
  //   await _queue.add(AudioSource.uri(
  //       Uri.parse('http://kwak.sytes.net/tracks/$id'),
  //       tag: MediaItem(
  //           id: id.toString(),
  //           title: _nowplaying['title'],
  //           artist: _nowplaying['artist'],
  //           album: _nowplaying['album'],
  //           artUri: Uri.parse('http://kwak.sytes.net/v0/cover/$id'))));
  //   await widget.player!.seekToNext();
  //   widget.player!.play();
  // }

  // void _playpause() {
  //   setState(() {
  //     if (widget.player!.playing) {
  //       widget.player!.pause();
  //       _icon = Icons.play_arrow;
  //     } else {
  //       widget.player!.play();
  //       _icon = Icons.pause;
  //     }
  //   });
  // }

  // void _showqueries(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       children = fullsongs;
  //       return;
  //     }
  //     children = List.castFrom(fullsongs);
  //     children = children.where((element) {
  //       return element[widget.selectedMenu.toString().split('.')[1]]
  //           .toString()
  //           .toLowerCase()
  //           .startsWith(query.toLowerCase());
  //     }).toList();
  //     if (children.isEmpty) children.add(emmpty);
  //     // children.removeWhere((element) {
  //     // });
  //   });
  // }

  // void _raisefrac() {
  //   setState(() {
  //     _frac = _frac == 1 ? 0 : 1;
  //   });
  // }

  // void _gonext() {
  //   setState(() {
  //     var id = _nowplaying['id'];
  //     var nexti = children.indexWhere((element) => element['id'] == id) + 1;
  //     _nowplaying = children[nexti];
  //     _play(_nowplaying['id']);
  //   });
  // }

  // void _goprevious() {
  //   setState(() {
  //     var id = _nowplaying['id'];
  //     var nexti = children.indexWhere((element) => element['id'] == id) - 1;
  //     _nowplaying = children[nexti];
  //     _play(_nowplaying['id']);
  //   });
  // }

  // void _clear() {
  //   setState(() {
  //     _searchbar.clear();
  //     children = fullsongs;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soncore'),
        centerTitle: true,
        leading: const IconButton(
          onPressed: null,
          icon: Icon(Icons.menu),
        ),
        bottom: AppBar(
          toolbarHeight: kToolbarHeight * frac,
          leading: Icon(Icons.search),
          title: TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText:
                  'Search: ${selectedMenu.toString().split('.')[1].replaceFirst(selectedMenu.toString().split('.')[1][0], selectedMenu.toString().split('.')[1][0].toUpperCase())}',
            ),
            controller: searchbar,
            onChanged: (value) => widget.showqueries(value),
          ),
          actions: [
            IconButton(
              onPressed: widget.clear,
              icon: const Icon(Icons.clear),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.raisefrac,
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<Sorts>(
            initialValue: selectedMenu,
            // Callback that sets the selected popup menu item.
            onSelected: (Sorts item) {
              setState(() {
                selectedMenu = item;
              });
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Sorts>>[
              const PopupMenuItem(child: Text('Sort by')),
              const PopupMenuDivider(
                height: 7,
              ),
              PopupMenuItem<Sorts>(
                value: Sorts.title,
                child: const Text('Title'),
                onTap: () {
                  if (selectedMenu == Sorts.title) {
                    children = children.reversed.toList();
                  } else {
                    selectedMenu = Sorts.title;
                    widget.sort();
                  }
                },
              ),
              PopupMenuItem<Sorts>(
                value: Sorts.artist,
                child: const Text('Artist'),
                onTap: () {
                  if (selectedMenu == Sorts.artist) {
                    children = children.reversed.toList();
                  } else {
                    selectedMenu = Sorts.artist;
                    widget.sort();
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Center(
          child: RefreshIndicator(
        onRefresh: () async {
          await widget.getitems();
          print(children.length);
        },
        child: ListView.builder(
          itemCount: children.length,
          // prototypeItem: ListTile(
          //   title: Text(children.first['title']),
          //   subtitle: Text(children.first['artist']),
          //   leading: Image.network(
          //       'http://kwak.sytes.net/v0/cover/${children.first['id']}'),
          //   onTap: (() => widget.audioHandler
          //       .initQueue(playlist: children, currentIndex: null)),
          // ),
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(children[i]['title']),
              subtitle: Text(children[i]['artist']),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  'http://kwak.sytes.net/v0/cover/${children[i]['id']}',
                  height: 60,
                  width: 60,
                ),
              ),
              onTap: () => widget.play(children[i]['id']),
            );
          },
        ),
      )),
    );
  }
}
