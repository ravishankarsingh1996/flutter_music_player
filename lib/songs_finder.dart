import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:music_player_app/songs_model.dart';
import 'package:permission_handler/permission_handler.dart';

import 'inherited_widget.dart';
import 'main.dart';
import 'package:flutter/services.dart';

class MyApp1 extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp1> {
  SongData songData;
  bool _isLoading = true;
  PermissionStatus _status;

  @override
  void initState() {
    super.initState();
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone)
        .then(updateStatus);
    _askPermisssion();
  }

  initPlatformState() async {
    _isLoading = true;
    var songs;
    try {
      songs = await MusicFinder.allSongs();
    } catch (e) {
      print("Failed to get songs: '${e.message}'.");
    }
    if (!mounted) return;
    setState(() {
      songData = new SongData((songs));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(songData, _isLoading, MyHomePage());
  }

  @override
  void dispose() {
    super.dispose();
    songData.audioPlayer.stop();
  }

  void updateStatus(PermissionStatus value) {
    switch (value) {
      case PermissionStatus.denied:
        _askPermisssion();
        break;
      case PermissionStatus.disabled:
        break;
      case PermissionStatus.granted:
        setState(() {
          initPlatformState();
        });
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.unknown:
        break;
    }

  }

  void _askPermisssion() {
    PermissionHandler().requestPermissions([PermissionGroup.microphone]).then(
        _onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> value) {
    final status = value[PermissionGroup.microphone];
    updateStatus(status);
  }
}
