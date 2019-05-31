import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player_app/play_screen.dart';
import 'package:music_player_app/songs_finder.dart';
import 'package:music_player_app/songs_model.dart';
import 'icon_row.dart';
import 'inherited_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyApp1(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<MaterialColor> _colors = Colors.primaries;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rootIW = MyInheritedWidget.of(context);
    SongData songData = rootIW.songData;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {},
          color: Colors.grey,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
          )
        ],
        elevation: 0.0,
      ),
      body: songData == null
          ? Container()
          : ListView.builder(
              itemCount: songData.allsongs.length,
              itemBuilder: (context, int index) {
                var s = songData.allsongs[index];
                final MaterialColor color = _colors[index % _colors.length];
                var artFile = s.albumArt == null
                    ? null
                    : new File.fromUri(Uri.parse(s.albumArt));

                return Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0),
                  child: Card(
                    color: Colors.red.withOpacity(0.6),
                    child: new ListTile(
                      dense: false,
                      leading: new Hero(
                        child: avatar(artFile, s.title, color),
                        tag: s.title,
                      ),
                      title: new Text(
                        s.title,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                      subtitle: new Text(
                        "By ${s.artist}",
                        style: TextStyle(color: Colors.white, fontSize: 9.0),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayScreen(songData, s),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
