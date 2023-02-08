import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:soncore/main.dart';

// ignore: must_be_immutable
class SongsPage extends StatefulWidget {
  void Function() showplaying;
  void Function() inititems;
  void Function() sort;
  Future<void> Function() getitems;
  Future<void> Function(int) play;
  void Function() playpause;
  void Function(String) showqueries;
  void Function() raisefrac;
  void Function() gonext;
  void Function() goprevious;
  void Function() clear;
  void Function() update;

  SongsPage(
      {super.key,
      required this.update,
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

  int? selectedsong;
  double offset = 0;

  @override
  void initState() {
    super.initState();
    var done = widget.getitems();
    done.then((value) => setState(() {}));
  }

  void plai(int id) async {
    await widget.play(id);
    setState(() {});
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
          leading: const Icon(Icons.search),
          title: TextField(
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
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
                  widget.raisefrac();
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
        },
        child: Scrollbar(
          interactive: true,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0),
            itemCount: children.length,
            itemBuilder: (context, i) {
              var songs = player.audioSource as ConcatenatingAudioSource;
              int? id;
              if (songs.length > 0) {
                var song = songs[player.currentIndex ?? 0] as UriAudioSource;
                id = int.parse(song.tag.id);
              }
              return children.isNotEmpty
                  ? GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 0) {
                          selectedsong = i;
                          setState(() {
                            if (offset < 80) offset += details.delta.dx;
                          });
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        offset = 0;
                        selectedsong = null;
                        if (details.primaryVelocity! > 0) {
                          queue.insert(
                              player.currentIndex! + 1,
                              AudioSource.uri(
                                Uri.parse(
                                    'http://kwak.sytes.net/tracks/${children[i]['id']}'),
                                tag: MediaItem(
                                  id: children[i]['id'].toString(),
                                  album: children[i]['album'],
                                  title: children[i]['title'],
                                  artist: children[i]['artist'],
                                  duration: Duration(
                                      seconds: children[i]['duration'].toInt()),
                                  artUri: Uri.parse(
                                      'http://kwak.sytes.net/v0/cover/${children[i]['id']}'),
                                ),
                              ));
                        }
                      },
                      child: ListTile(
                        contentPadding: selectedsong == i
                            ? EdgeInsets.only(left: offset)
                            : null,
                        selected: id == children[i]['id'],
                        selectedTileColor: Theme.of(context).primaryColor,
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
                        trailing: Text(
                            '${(children[i]['duration'] / 60).floor() < 10 ? (children[i]['duration'] / 60).floor().toString().padLeft(2, '0') : (children[i]['duration'] / 60).floor()}:${(children[i]['duration'] % 60).floor() < 10 ? (children[i]['duration'] % 60).floor().toString().padLeft(2, '0') : (children[i]['duration'] % 60).floor()}'),
                        onTap: () {
                          plai(children[i]['id']);
                        },
                      ),
                    )
                  : const Center();
            },
          ),
        ),
      )),
    );
  }
}
