import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'player.dart';

/// A list of tiles showing all the audio sources added to the audio player.
///
/// Audio sources are displayed with a `ListTile` with a leading image (the
/// artwork), and the title of the audio source.
class Playlist extends StatefulWidget {
  const Playlist(this._audioPlayer, this.callback, {super.key});

  final Function callback;
  final _audioPlayer;

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SequenceState?>(
      stream: widget._audioPlayer.sequenceStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final sequence = state?.sequence ?? [];
        return ListView(
          children: [
            for (var i = 0; i < sequence.length; i++)
              Card(
                color: i == state?.currentIndex
                    ? Theme.of(context).colorScheme.primary
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ListTile(
                  selected: i == state?.currentIndex,
                  trailing: Image.asset(sequence[i].tag.artwork),
                  title: Text(
                    sequence[i].tag.title,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: i == state?.currentIndex
                          ? const Color.fromARGB(255, 253, 220, 220)
                          : null,
                    ),
                  ),
                  onTap: () {
                    widget._audioPlayer.seek(Duration.zero, index: i);
                    widget.callback(i);
                    setState(() {
                      Player.currentIndex = i;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
