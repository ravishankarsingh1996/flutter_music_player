import 'package:flutter/material.dart';
import 'package:music_player_app/songs_model.dart';


class MyInheritedWidget extends InheritedWidget{
  final SongData songData;
  final bool isLoading;
  const MyInheritedWidget(this.songData,this.isLoading,child):super(child:child);

  static MyInheritedWidget of(BuildContext context){
    return context.inheritFromWidgetOfExactType(MyInheritedWidget);
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return songData!=oldWidget.songData||isLoading!=oldWidget.isLoading;
  }



}