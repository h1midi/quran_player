import 'dart:convert';
import 'package:http/http.dart' as htp;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/audio_metadata.dart';
import './player_buttons.dart';
import './playlist.dart';

/// An audio player.
///
/// At the bottom of the page there is [PlayerButtons], while the rest of the
/// page is filled with a [PLaylist] widget.
class Player extends StatefulWidget {
  static var currentIndex = 0;
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<QuranSurah> surahList = [];

  Future<void> fetchSurahList() async {
    final response = await htp
        .get(Uri.parse('https://www.mp3quran.net/api/v3/suwar?language=ar'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final surahData = data['suwar'];
      setState(() {
        surahList = surahData
            .map<QuranSurah>((json) => QuranSurah.fromJson(json))
            .toList();
        print(surahList);
        _audioPlayer
            .setAudioSource(ConcatenatingAudioSource(children: [
              for (var i = 1; i <= 114; i++)
                AudioSource.uri(
                  Uri.parse(
                      "https://server11.mp3quran.net/a_jbr/${i.toString().padLeft(3, '0')}.mp3"),
                  tag: AudioMetadata(
                    title: "سورة ${surahList[i - 1].name}",
                    artwork: "assets/images/ali_jaber.jpg",
                  ),
                ),
            ]))
            .whenComplete(() => setState(() {
                  callback;
                }))
            .onError((error, stackTrace) => null);
        _audioPlayer.sequenceStateStream.listen((event) {
          callback(event!.currentIndex);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    /* -------------use this in the online version------------- */
    fetchSurahList();
    /* -------------use this in the offline version------------- */
    // _audioPlayer
    //         .setAudioSource(ConcatenatingAudioSource(children: [
    //           for (var i = 1; i <= 114; i++)
    //             AudioSource.asset(
    //                 "assets/mp3/${i.toString().padLeft(3, '0')}.mp3",
    //                 tag: AudioMetadata(
    //                   title: "سورة ${surahList[i - 1].name}",
    //                   artwork: "assets/ali_jaber.jpg",
    //                 ))
    //         ]))
    //         .whenComplete(() => setState(() {
    //               callback;
    //             }))
    //         .onError((error, stackTrace) => null);
    //     _audioPlayer.sequenceStateStream.listen((event) {
    //       callback(event!.currentIndex);
    //     });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void callback(int currentIndex) {
    setState(() {
      Player.currentIndex = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف كامل بصوت علي جابر'),
        centerTitle: true,
      ),
      body: Center(
        child: SafeArea(
          child: surahList.isEmpty
              ? const Center(
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.deepOrangeAccent,
                    semanticsLabel: 'جاري التحميل...',
                  )),
                )
              : Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      margin: const EdgeInsets.only(
                          left: 38, right: 38, top: 18, bottom: 18),
                      child: Image.asset(
                        height: MediaQuery.of(context).size.height * 0.3,
                        "assets/ali_jaber.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      surahList.isNotEmpty
                          ? "سورة ${surahList[Player.currentIndex].name}"
                          : '',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    StreamBuilder<Object>(
                      initialData: const Duration(seconds: 0),
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return IconButton(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh_rounded),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                            color: Colors.deepOrangeAccent,
                            semanticsLabel: 'جاري التحميل...',
                          );
                        }
                        Duration bufferedPosition = snapshot.data as Duration;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(18.0, 10, 18, 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${bufferedPosition.inHours}:${bufferedPosition.inMinutes % 60}:${(bufferedPosition.inSeconds % 60).toString().padLeft(2, '0')}'),
                                  _audioPlayer.duration != null
                                      ? Text(
                                          '${_audioPlayer.duration!.inHours}:${_audioPlayer.duration!.inMinutes % 60}:${(_audioPlayer.duration!.inSeconds % 60).toString().padLeft(2, '0')}')
                                      : const Text('0:00:00'),
                                ],
                              ),
                              _audioPlayer.duration != null
                                  ? LinearProgressIndicator(
                                      value: bufferedPosition.inMilliseconds
                                              .toDouble() /
                                          _audioPlayer.duration!.inMilliseconds
                                              .toDouble(),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      backgroundColor: Colors.grey,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(18)),
                                    )
                                  : const LinearProgressIndicator(
                                      value: 0,
                                      backgroundColor: Colors.grey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(18)),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                    PlayerButtons(_audioPlayer),
                    Expanded(child: Playlist(_audioPlayer, callback)),
                  ],
                ),
        ),
      ),
    );
  }
}
