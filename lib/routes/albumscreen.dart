import 'package:flutter/material.dart';
import 'package:soncore/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

// ignore: must_be_immutable
class AlbumScreen extends StatefulWidget {
  void Function() sort;
  void Function(int) play;
  void Function() update;
  AlbumScreen(
      {super.key,
      required this.sort,
      required this.play,
      required this.update});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  var songs = [];

  Future<void> _play(id) async {
    if (queue.children.isEmpty) {
      for (var song in songs) {
        await queue.add(AudioSource.uri(Uri.parse('$url/tracks/${song['id']}'),
            tag: MediaItem(
              id: song['id'].toString(),
              title: song['title'],
              artist: song['artist'],
              album: song['album'],
              artUri: Uri.parse('$url/v0/cover/${song['id']}'),
            )));
      }
    }
    else {
      var q = queue[0] as UriAudioSource;
      if (songs.first['album'] != q.tag.album) {
        queue.clear();
        for (var song in songs) {
          await queue.add(AudioSource.uri(Uri.parse('$url/tracks/${song['id']}'),
            tag: MediaItem(
              id: song['id'].toString(),
              title: song['title'],
              artist: song['artist'],
              album: song['album'],
              artUri: Uri.parse('$url/v0/cover/${song['id']}'),
          )));
        }
      }
    }
    for (var song in songs) {
      if (song['id'] == id) {
        setState(() {
          nowplaying = song;
        });
        break;
      }
    }
    setState(() {
      var index = queue.sequence
          .indexWhere((element) => element.tag.id == id.toString());
      player.seek(Duration.zero, index: index);
      player.play();
      hasplayed = true;
      icon = Icons.pause;
    });
    setState(() {
      widget.update();
    });
  }

  Future<void> getalbum() async {
    var albumtitle = children.firstWhere((element) => element['id'] == album)['album'];
    var data = fullsongs.where((element) => element['album'] == albumtitle);
    songs = data.toList();
  }

  @override
  void initState() {
    getalbum();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: Column(children: [
          Container(
            height: 80,
          ),
          SizedBox(
              height: 200,
              child: Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network('$url/v0/cover/$album')))),
          Container(height: 20),
          Center(
              child: Text(
                  children
                      .firstWhere((element) => element['id'] == album)['album'],
                  style: const TextStyle(fontSize: 35))),
          Container(height: 20),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: songs.length,
                  itemBuilder: (context, i) {
                    return songs.isNotEmpty && i < songs.length
                        ? ListTile(
                            selected: nowplaying != null? nowplaying['id'] == songs[i]['id'] : false,
                            selectedTileColor: Theme.of(context).primaryColor,
                            title: Text(
                              songs[i]['title'],
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(songs[i]['artist']),
                            trailing: Text(
                                '${(songs[i]['duration'] / 60).floor() < 10 ? (songs[i]['duration'] / 60).floor().toString().padLeft(2, '0') : (songs[i]['duration'] / 60).floor()}:${(songs[i]['duration'] % 60).floor() < 10 ? (songs[i]['duration'] % 60).floor().toString().padLeft(2, '0') : (songs[i]['duration'] % 60).floor()}'),
                            onTap: () async {
                              await _play(songs[i]['id']);
                              setState(() {});
                            })
                        : const Center();
                  }))
        ])),
        onWillPop: () {
          selected = 2;
          widget.update();
          return Future.value(false);
        });
  }
}
