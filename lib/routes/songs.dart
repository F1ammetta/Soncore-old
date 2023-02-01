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

  @override
  void initState() {
    super.initState();
    player.setAudioSource(queue);
    var done = widget.getitems();
    done.then((value) => setState(() {}));
    if (children.isNotEmpty) children.add(emmpty);
  }

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
            onChanged: (value) {
              setState(() {
                widget.showqueries(value);
              });
            },
          ),
          actions: [
            IconButton(
              onPressed: () => {
                setState(() {
                  widget.clear();
                })
              },
              icon: const Icon(Icons.clear),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                widget.raisefrac();
              });
            },
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
                    setState(() {
                      children = children.reversed.toList();
                    });
                  } else {
                    setState(() {
                      selectedMenu = Sorts.title;
                      widget.sort();
                    });
                  }
                },
              ),
              PopupMenuItem<Sorts>(
                value: Sorts.artist,
                child: const Text('Artist'),
                onTap: () {
                  if (selectedMenu == Sorts.artist) {
                    setState(() {
                      children = children.reversed.toList();
                    });
                  } else {
                    setState(() {
                      selectedMenu = Sorts.artist;
                      widget.sort();
                    });
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
          setState(() {});
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
