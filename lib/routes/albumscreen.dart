import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
    if (songs.length != queue.length) {
      queue.clear();
      for (var song in songs) {
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
          songs.firstWhere((element) => element['id'] == id, orElse: (() {
        return null;
      }));
      var index = songs.indexOf(nowplaying);
      player.seek(Duration.zero, index: index);
      player.play();
      hasplayed = true;
      icon = Icons.pause;
    });
    widget.update();
  }

  Future<void> getalbum() async {
    try {
      var res = await get(Uri.parse('http://kwak.sytes.net/v0/album/$album'));
      var body = utf8.decode(res.bodyBytes);
      var data = jsonDecode(body) as List;
      setState(() {
        if (data.length != children.length) {
          songs = data;
        }
      });
      widget.sort();
    } catch (e) {
      setState(() {
        songs.clear();
      });
    }
    setState(() {});
    widget.update();
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
                      child: Image.network(
                          'http://kwak.sytes.net/v0/cover/$album')))),
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
                    var sons = player.audioSource as ConcatenatingAudioSource;
                    int? id;
                    if (!(sons.length > songs.length)) {
                      if (sons.length > 0 && queue.length == songs.length) {
                        var son =
                            sons[player.currentIndex ?? 0] as UriAudioSource;
                        id = int.parse(son.tag.id);
                      }
                    }
                    return songs.isNotEmpty
                        ? ListTile(
                            selected: id == songs[i]['id'],
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
