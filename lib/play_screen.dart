import 'dart:async';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:fluttery_audio/fluttery_audio.dart';
import 'package:music_player_app/songs_model.dart';

import 'package:permission_handler/permission_handler.dart';

import 'custom_button.dart';

enum PlayerState { stopped, playing, paused }

class PlayScreen extends StatefulWidget {
  final Song song;
  final SongData songData;
  PlayScreen(this.songData,this.song, {Key key, this.title}) : super(key: key);
  bool nowPlayTap;
  final String title;

  @override
  State<StatefulWidget> createState() {
    return PlayScreenState();
  }

}

class PlayScreenState extends State<PlayScreen> {
  MusicFinder audioPlayer;
  Song song;
  PlayerState playerState;
  Duration position;
  Duration duration;


  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;


  @override
  void initState() {
    super.initState();
    initPlayer();
  }
  initPlayer() {
    if(audioPlayer==null){
      audioPlayer=widget.songData.audioPlayer;
    }
    setState(() {
      song = widget.song;
      if (widget.nowPlayTap == null || widget.nowPlayTap == false) {
        if (playerState != PlayerState.stopped) {
          stop();
        }
      }
      play(song);
    });
    audioPlayer.setDurationHandler((d) => setState(() {
      duration = d;
    }));

    audioPlayer.setPositionHandler((p) => setState(() {
      position = p;
    }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }
  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }
  void play(Song s) async {
    if (s != null) {
      final result = await audioPlayer.play(s.uri, isLocal: true);
      if (result == 1)
        setState(() {
          playerState = PlayerState.playing;
        });
    }
  }
  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future prev(SongData s) async {
    stop();
    play(s.prevSong);
  }
  Future next(SongData s) async {
    stop();
    setState(() {
      play(s.nextSong);
    });
  }
  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
    play(widget.songData.nextSong);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () {

          },
          color: Colors.grey,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu,color: Colors.white,),

          )
        ],
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[

          Expanded(
            child: Center(
              child: Container(
                width: 125.0,
                height: 125.0,
                child: ClipOval(
                  child: Image.asset('assets/waterfall.jpg',fit: BoxFit.fill),

                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 100.0,
              child: Visualizer(
                builder: (BuildContext context, List<int> fft) {
                  return  CustomPaint(
                    painter: VisualizerPainter(
                        fft: fft,
                        color: Colors.blue.withOpacity(0.55),
                        height: 100.0
                    ),

                  );
                },
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 20.0,bottom: 30.0),
            color: Colors.red.withOpacity(0.55),
            width: double.infinity,
            child: Column(
              children: <Widget>[
                RichText(text: TextSpan(
                    text: '', children: [
                  TextSpan(
                      text: 'Song Title\n',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.5,
                        letterSpacing: 4.0,
                      )
                  ),
                  TextSpan(
                    text: 'Artist Name',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.75),
                      height: 1.5,
                      letterSpacing: 3.0,
                    ),
                  ),
                ]
                )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: <Widget>[
                      duration == null ? new Container() : new Slider(
                          value: position?.inMilliseconds?.toDouble() ?? 0,
                          onChanged: (double value) =>
                              audioPlayer.seek((value / 1000).roundToDouble()),
                          min: 0.0,
                          max: duration.inMilliseconds.toDouble()

                      ),

                      Row(
                        children: <Widget>[
                          Expanded(child: Container()),
                          CustomButton(Icons.skip_previous, () => prev(widget.songData)),
                          Expanded(child: Container()),
                          CustomButton(isPlaying ? Icons.pause:Icons.play_arrow,isPlaying ? () => pause() : () => play(widget.song)),

                          Expanded(child: Container()),
                          new CustomButton(Icons.skip_next, () => next(widget.songData)),
                          Expanded(child: Container()),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisualizerPainter extends CustomPainter {

  final List<int> fft;
  final double height;
  final Color color;
  final Paint wavePaint;

  VisualizerPainter({
    this.fft,
    this.height,
    this.color,
  }) : wavePaint = new Paint()
    ..color = color.withOpacity(0.55)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    return _renderWaves(canvas, size);
  }
  void _renderWaves(Canvas canvas, Size size) {
    final histogramLow = _createHistogram(fft, 15, 2, ((fft.length) / 4).floor());
    final histogramHigh = _createHistogram(fft, 15, (fft.length / 4).ceil(), (fft.length / 2).floor());

    _renderHistogram(canvas, size, histogramLow);
    _renderHistogram(canvas, size, histogramHigh);
  }

  void _renderHistogram(Canvas canvas, Size size, List<int> histogram) {
    if (histogram.length == 0) {
      return;
    }

    final pointsToGraph = histogram.length;
    final widthPerSample = (size.width / (pointsToGraph - 2)).floor();

    final points = new List<double>.filled(pointsToGraph * 4, 0.0);

    for (int i = 0; i < histogram.length - 1; ++i) {
      points[i * 4] = (i * widthPerSample).toDouble();
      points[i * 4 + 1] = size.height - histogram[i].toDouble();

      points[i * 4 + 2] = ((i + 1) * widthPerSample).toDouble();
      points[i * 4 + 3] = size.height - (histogram[i + 1].toDouble());
    }

    Path path = new Path();
    path.moveTo(0.0, size.height);
    path.lineTo(points[0], points[1]);
    for (int i = 2; i < points.length - 4; i += 2) {
      path.cubicTo(
          points[i - 2] + 10.0, points[i - 1],
          points[i] - 10.0, points [i + 1],
          points[i], points[i + 1]
      );
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  List<int> _createHistogram(List<int> samples, int bucketCount, [int start, int end]) {
    if (start == end) {
      return const [];
    }

    start = start ?? 0;
    end = end ?? samples.length - 1;
    final sampleCount = end - start + 1;

    final samplesPerBucket = (sampleCount / bucketCount).floor();
    if (samplesPerBucket == 0) {
      return const [];
    }

    final actualSampleCount = sampleCount - (sampleCount % samplesPerBucket);
    List<int> histogram = new List<int>.filled(bucketCount, 0);

    // Add up the frequency amounts for each bucket.
    for (int i = start; i <= start + actualSampleCount; ++i) {
      // Ignore the imaginary half of each FFT sample
      if ((i - start) % 2 == 1) {
        continue;
      }

      int bucketIndex = ((i - start) / samplesPerBucket).floor();
      histogram[bucketIndex] += samples[i];
    }

    // Massage the data for visualization
    for (var i = 0; i < histogram.length; ++i) {
      histogram[i] = (histogram[i] / samplesPerBucket).abs().round();
    }

    return histogram;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}