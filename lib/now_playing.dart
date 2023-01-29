// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:soncore/main.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:text_scroll/text_scroll.dart';

class NowPlaying extends StatefulWidget {
  Stream<PositionData> positionDataStream;
  IconData icon;
  void Function() goprevious;
  void Function() playpause;
  void Function() gonext;
  void Function() showplaying;

  NowPlaying(
      {super.key,
      required this.positionDataStream,
      required this.gonext,
      required this.goprevious,
      required this.icon,
      required this.playpause,
      required this.showplaying});

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  @override
  Widget build(BuildContext context) {
    return hasplayed
        ? Container(
            constraints: const BoxConstraints(
                maxHeight: kToolbarHeight + 5, maxWidth: 385),
            child: Hero(
              tag: 0,
              child: Column(
                children: [
                  hasplayed
                      ? StreamBuilder<PositionData>(
                          stream: widget.positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return ProgressBar(
                              total: positionData?.duration ?? Duration.zero,
                              progress: positionData?.position ?? Duration.zero,
                              buffered: positionData?.bufferedPosition ??
                                  Duration.zero,
                              timeLabelLocation: TimeLabelLocation.none,
                              thumbRadius: 0,
                              barHeight: hasplayed ? 5 : 0,
                            );
                          },
                        )
                      : const Center(),
                  // Center(
                  //   widthFactor: 1,
                  //   heightFactor: 1,
                  //   child: Container(
                  //     alignment: const Alignment(0.0, 0.2),
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(5),
                  //       child: AppBar(
                  //         toolbarHeight: hasplayed ? kToolbarHeight : 0,
                  //         leading: hasplayed
                  //             ? Padding(
                  //                 padding: const EdgeInsets.all(4.5),
                  //                 child: ClipRRect(
                  //                   borderRadius: BorderRadius.circular(9.0),
                  //                   child: Image.network(
                  //                     'http://kwak.sytes.net/v0/cover/${nowplaying['id']}',
                  //                     height: 50,
                  //                     width: 50,
                  //                   ),
                  //                 ),
                  //               )
                  //             : const Card(
                  //                 child: AspectRatio(aspectRatio: 1.0),
                  //               ),
                  //         title: hasplayed
                  //             ? GestureDetector(
                  //                 onTap: widget.showplaying,
                  //                 child: TextScroll(
                  //                   nowplaying['title'] +
                  //                       '  -  ' +
                  //                       nowplaying['artist'] +
                  //                       ' ' * nowplaying['title'].length,
                  //                   mode: TextScrollMode.endless,
                  //                   velocity: const Velocity(
                  //                       pixelsPerSecond: Offset(30, 0)),
                  //                 ),
                  //               )
                  //             : const Text(''),
                  //         titleTextStyle: const TextStyle(fontSize: 20),
                  //         actions: [
                  //           IconButton(
                  //               onPressed: () {
                  //                 widget.goprevious();
                  //               },
                  //               icon: const Icon(Icons.skip_previous)),
                  //           IconButton(
                  //               onPressed: widget.playpause,
                  //               icon: Icon(widget.icon)),
                  //           IconButton(
                  //               onPressed: () {
                  //                 widget.gonext();
                  //               },
                  //               icon: const Icon(Icons.skip_next))
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // )
                  Image.network(
                    'http://kwak.sytes.net/v0/cover/${nowplaying['id']}',
                    height: 50,
                    width: 50,
                  ),
                ],
              ),
            ),
          )
        : const Center();
  }
}
