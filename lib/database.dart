
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'model/Movie.dart';

class MovieDatabase {
  static final MovieDatabase _movieDatabase = new MovieDatabase._internal();

  final String tableName = "Movies";

  Database db;

  static MovieDatabase get() {


    return _movieDatabase;
  }

  MovieDatabase._internal();

  Future init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "demo.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              "CREATE TABLE $tableName ("
                  "${Movie.db_id} STRING PRIMARY KEY,"
                  "${Movie.db_title} TEXT,"
                  "${Movie.db_url} TEXT,"
                  "${Movie.db_star} BIT,"
                  "${Movie.db_notes} TEXT"
                  ")");
        });


  }

  /// Get a book by its id, if there is not entry for that ID, returns null.
  Future<Movie> getMovie(String id) async{
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE ${Movie.db_id} = "$id"');
    if(result.length == 0)return null;
    return new Movie.fromMap(result[0]);
  }


  /// Inserts or replaces the book.
  Future updateMovie(Movie movie) async {
    await db.inTransaction(() async {
      await db.rawInsert(
          'INSERT OR REPLACE INTO '
              '$tableName(${Movie.db_id}, ${Movie.db_title}, ${Movie.db_url}, ${Movie.db_star}, ${Movie.db_notes})'
              ' VALUES("${movie.id}", "${movie.title}", "${movie.url}", ${movie.starred? 1:0}, "${movie.notes}")');
    });
  }

  Future close() async {
    return db.close();
  }



}

