import 'package:flutter/material.dart';
import 'database.dart';
import 'model/Movie.dart';
import 'package:rxdart/rxdart.dart';

class MovieNotesPage extends StatefulWidget {

  MovieNotesPage(this.movie);

  final Movie movie;


  @override
  State<StatefulWidget> createState() => new _MovieNotesPageState();

}


  class _MovieNotesPageState extends State<MovieNotesPage> {

  TextEditingController _textController;

  final subject = new PublishSubject<String>();

  @override
  void dispose() {
    subject.close();
    super.dispose;
  }

 @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: widget.movie.notes);
    subject.stream.debounce(new Duration(milliseconds: 400)).listen((text){
      widget.movie.notes = text;
      MovieDatabase.get().updateMovie(widget.movie);
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: const Text("Notes"),),
      body: new Container(
        child: new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              new Hero(
                  child: new Image.network(widget.movie.url),
                  tag: widget.movie.id
              ),
              new Expanded(
                child: new Card(
                  child: new Padding(
                    padding: new EdgeInsets.all(8.0),
                    child: new TextField(
                      style: new TextStyle(fontSize: 18.0, color: Colors.black),
                      maxLines: null,
                      decoration: null,
                      controller: _textController,
                      onChanged: (text) => subject.add(text),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  }

