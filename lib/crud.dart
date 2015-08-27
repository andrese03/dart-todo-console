library crud;

import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart';

// Database Object
Db db;
// Determines if there's a database connection
bool dbOpened = false;
// Connection String
String connectionString = 'mongodb://localhost:27017/recogeme';

// Open a Database Connection
Future openConnection () {
  if (!dbOpened) {
    db = new Db(connectionString);
    dbOpened = true;
    return db.open();
  }
  else {
    return new Future(null).then((_) => true);
  }
}

// Close a Database Connection
Future closeConnection () {
  if (dbOpened) {
    return db.close();
  }
  else {
    throw 'You must open a database connection';
  }
}

// Class Handler for CRUD Operations
class Crud {
  String collectionName; // Collection Name
  DbCollection collection; // Collection Object

  // Constructor
  Crud(String collectionName) {
     this.collectionName = collectionName;
     this.collection = db.collection(collectionName);
  }

  // Gets all records
  Future read (Map query) {
    return collection.find(where.sortBy('_id')).toList();
  }

  // Gets one record by its ObjectId
  Future readOne (var id) {
    return collection.findOne(where.eq('_id', id));
  }

  // Inserts a record
  Future create (Map value) async {
    value['_id'] = await _getSequenceForCollection();
    return collection.insert(value, writeConcern: WriteConcern.ACKNOWLEDGED);
  }

  // Updates a record by it's ObjectId
  Future update(var id, Map value) {
    ModifierBuilder customModify = new ModifierBuilder();
    value.forEach((key, value) => customModify.set(key, value));
    return collection.update(where.eq('_id', id), customModify);
  }

  // Deletes a record by it's ObjectId
  Future delete(var id) {
    return collection.remove(where.eq('_id', id));
  }

  // Deletes all records
  Future deleteAll() {
    return collection.remove();
  }

  // Gets all records
  Future count (Map query) {
    return collection.count();
  }

  // Gets last sequence record
  Future _getSequenceForCollection({ Map query, Map update }) {
    Map message = {};
    message["findAndModify"] = 'counter';
    message["query"] = { '_id': collectionName };
    message["update"] = { '\$inc': { 'seq': 1 } };
    return db.executeDbCommand(DbCommand.createQueryDbCommand(db, message))
    .then((record) => record['value']['seq']);
  }

}