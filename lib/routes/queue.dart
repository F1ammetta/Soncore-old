import 'package:flutter/material.dart';
import 'package:soncore/main.dart';
import 'package:just_audio/just_audio.dart';

// ignore: must_be_immutable
class QueuePage extends StatefulWidget {
  void Function() update;
  QueuePage({super.key, required this.update});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Queue'),
          ),
          body: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: queue.length,
              itemBuilder: ((context, index) {
                var song = queue[index] as UriAudioSource;
                return ListTile(
                  selectedTileColor: Theme.of(context).primaryColor,
                  selected: index == player.currentIndex,
                  onTap: () {
                    setState(() {
                      selected = 4;
                    });
                    widget.update();
                    player.seek(Duration.zero, index: index);
                    setState(() {});
                  },
                  title: Text(song.tag.title),
                  subtitle: Text(song.tag.artist),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      '$url/v0/cover/${song.tag.id}',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        queue.removeAt(index);
                      });
                    },
                  ),
                );
              })),
        ),
        onWillPop: () {
          setState(() {
            selected = 4;
          });
          widget.update();
          return Future.value(false);
        });
  }
}
