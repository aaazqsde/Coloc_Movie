import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'movie_notes_page.dart';
import 'database.dart';
import 'model/Movie.dart';
import 'utils/utils.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Movie search the App',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: {
        '/': (BuildContext context) => new MyHomePage(title: 'Movie Search'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> _items = new List();

  final subject = new PublishSubject<String>();

  bool _isLoading = false;

  void _textChanged(String text) {
    if(text.isEmpty) {
      setState((){_isLoading = false;});
      _clearList();
      return;
    }
    setState((){_isLoading = true;});
    _clearList();
    http.get("https://api.themoviedb.org/3/search/movie?api_key=11fbce624b26a6399db07560f5bd5fed&query=$text")
        .then((response) => response.body)
        .then(JSON.decode)
        .then((map) => map["results"])
        .then((list) {list.forEach(_addBook);})
        .catchError(_onError)
        .then((e){setState((){_isLoading = false;});});
  }

  void _onError(dynamic d) {
    setState(() {
      _isLoading = false;
    });
  }

  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  void _addBook(dynamic movie) {
    setState(() {
      _items.add(new Movie(
          title: movie["title"],
          url: movie["poster_path"],
          id: movie["id"].toString()
      ));
    });
  }

  @override
  void dispose() {
    subject.close();
    MovieDatabase.get().close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subject.stream.debounce(new Duration(milliseconds: 600)).listen(_textChanged);
    MovieDatabase.get().init();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: 'Choose a book',
              ),
              onChanged: (string) => (subject.add(string)),
            ),
            _isLoading? new CircularProgressIndicator(): new Container(),
            new Expanded(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  return new MovieCard(_items[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: 'Choose a Movie',
              ),
              onChanged: (string) => (subject.add(string)),
            ),
            _isLoading? new CircularProgressIndicator(): new Container(),
            new Expanded(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Card(
                      child: new Padding(
                          padding: new EdgeInsets.all(8.0),
                          child: new Row(
                            children: <Widget>[
                              _items[index].url != null? new Image.network("https://image.tmdb.org/t/p/w92" + _items[index].url): new Container(),
                              new Flexible(
                                child: new Text(_items[index].title, maxLines: 10),
                              ),
                            ],
                          )
                      )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/


class MovieCard extends StatefulWidget {


  MovieCard(this.movie);

  final Movie movie;

  @override
  State<StatefulWidget> createState() => new MovieCardState();

}

class MovieCardState extends State<MovieCard> {

  Movie movieState;


  @override
  void initState() {
    super.initState();
    movieState = widget.movie;
    MovieDatabase.get().getMovie(widget.movie.id)
        .then((movie){
      if (movie == null) return;
      setState((){
        movieState = movie;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: (){
        Navigator.of(context).push(
            new FadeRoute(
              builder: (BuildContext context) => new MovieNotesPage(movieState),
              settings: new RouteSettings(name: '/notes', isInitialRoute: false),
            ));
      },
      child: new Card(
          child: new Container(
            height: 200.0,
            child: new Padding(
                padding: new EdgeInsets.all(8.0),
                child: new Row(
                  children: <Widget>[
                    movieState.url != null?
                    new Hero(
                      child: new Image.network("https://image.tmdb.org/t/p/w92" + movieState.url),
                      tag: movieState.id,
                    ):
                    new Container(),
                    new Expanded(
                      child: new Stack(
                        children: <Widget>[
                          new Align(
                            child: new Padding(
                              child: new Text(movieState.title, maxLines: 10),
                              padding: new EdgeInsets.all(8.0),
                            ),
                            alignment: Alignment.center,
                          ),
                          new Align(
                            child: new IconButton(
                              icon: movieState.starred? new Icon(Icons.star): new Icon(Icons.star_border),
                              color: Colors.black,
                              onPressed: (){
                                setState(() {
                                  movieState.starred = !movieState.starred;
                                });
                                MovieDatabase.get().updateMovie(movieState);
                              },
                            ),
                            alignment: Alignment.topRight,
                          ),

                        ],
                      ),
                    ),

                  ],
                )
            ),
          )
      ),
    );
  }

}
