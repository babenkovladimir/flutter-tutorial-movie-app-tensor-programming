import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_movie_app/model/model.dart';
import 'package:flutter_movie_app/screens/moview_view.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

const apiKey = '6058a7063c7c4613d9061be461ac0618';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Movie> movies = List();
  bool hasLoaded = false;
  //MovieDatabase db;

  final PublishSubject<String> subject = PublishSubject();

  @override
  void dispose() {
    subject.close();
    super.dispose();
    //db.closeDb();
  }

  void searchMovies(String query) {
    if (query.isEmpty) {
      setState(() {
        hasLoaded = true;
      });
    }
    setState(() => hasLoaded = false);

    http
        .get('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query')
        .then((res) => (res.body))
        .then(json.decode)
        .then((map) => map["results"])
        .then((movies) => movies.forEach(addMovie))
        .catchError(onError)
        .then((e) {
      setState(() {
        hasLoaded = true;
      });
    });
  }

  void onError(dynamic d) {
    setState(() {
      hasLoaded = true;
    });
  }

  void addMovie(item) {
    setState(() {
      movies.add(Movie.fromJson(item));
      print('${movies.map((m) => m.title)}');
    });
  }

  @override
  void initState() {
    super.initState();
    hasLoaded = true;
    //db = MovieDatabase();
    //db.initDB();
    subject.stream.debounce(Duration(milliseconds: 400)).listen(searchMovies);
  }

  @override
  Widget build(BuildContext context) {

     return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (String string) => (subject.add(string)),
            ),
            hasLoaded ? Container() : CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: movies.length,
                itemBuilder: (BuildContext context, int index) {
                  return new MovieView(movies[index]);
                },
              ),
            ),
          ],
        ),
    );
  }
}
