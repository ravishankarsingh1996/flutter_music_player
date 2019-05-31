import 'dart:math';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';

class SongData {
  List<Song> allsongs;
  int _currentSongIndex = -1;
  MusicFinder musicFinder;
  SongData(this.allsongs) {
    musicFinder = new MusicFinder();
  }

  List<Song> get songs => allsongs;
  int get length => allsongs.length;
  int get songNumber => _currentSongIndex + 1;

  setCurrentIndex(int index) {
    _currentSongIndex = index;
  }

  int get currentIndex => _currentSongIndex;

  Song get nextSong {
    if (_currentSongIndex < length) {
      _currentSongIndex++;
    }
    if (_currentSongIndex >= length) return null;
    return allsongs[_currentSongIndex];
  }

  Song get prevSong {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
    }
    if (_currentSongIndex < 0) return null;
    return allsongs[_currentSongIndex];
  }

  MusicFinder get audioPlayer => musicFinder;
}
