import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PersistenceService {
  static final PersistenceService _persistenceService = new PersistenceService.internal();

  factory PersistenceService() => _persistenceService;

  static Database _db;

  PersistenceService.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    // Construct a file path to copy database to
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "stations.db");

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('assets', 'stations.db'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasePath = join(appDocDir.path, 'stations.db');
    return await openDatabase(databasePath);
  }

  Future<List> executeQuery(String query) async {
    var client = await db;
    var result = await client.rawQuery(query);
    return result;
  }
}
