import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_movie_app/model/model.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

const apiKey = '6058a7063c7c4613d9061be461ac0618';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Searcher',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<Movie> movies = List();
  bool hasLoaded = false;

  final PublishSubject<String> subject = PublishSubject();

  @override
  void dispose() {
    subject.close();
    super.dispose();
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
    subject.stream.debounce(Duration(milliseconds: 400)).listen(searchMovies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
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
      ),
    );
  }
}

class MovieView extends StatefulWidget {
  final Movie movie;

  MovieView(this.movie);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MovieViewState();
  }
}

class MovieViewState extends State<MovieView> {
  Movie movieState;

  @override
  void initState() {
    super.initState();
    movieState = widget.movie;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200.0,
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            movieState.posterPath != null
                ? Hero(
                    child: Image.network("https://image.tmdb.org/t/p/w92${movieState.posterPath}"),
                    tag: movieState.id,
                  )
                : Container(),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        movieState.title,
                        maxLines: 10,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: movieState.favored ? Icon(Icons.star) : Icon(Icons.star_border),
                      onPressed: () {},
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(Icons.arrow_downward),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
