library commands;

import 'dart:io';
import 'dart:async';
import 'package:recogeme_practica_2/task.dart';
import 'package:args/command_runner.dart';
import 'package:recogeme_practica_2/crud.dart' as database;

// Closes the IO buffer
void commandLineClose (_) {
  (database.dbOpened) ? database.closeConnection() : null;
  exit(0);
}

// Catch any wrong command
void commandLineErrorHandler (error) {
  (database.dbOpened) ? database.closeConnection() : null;
  if (error is! UsageException) throw error;
  print(error);
  exit(64); // Exit code 64 indicates a usage error.
}

Future openDatabaseConnection () async =>
  await database.openConnection();

class ListCommand extends Command {
  final name = "list";
  final description = "Shows all tasks.";

  ListCommand();

  Future run() async{
    await openDatabaseConnection();
    List tasks = await new database.Crud('todo').read({});
    print('\nToDo Console Application!');
    tasks.forEach((task) => print(new Task.fromJson(task).toString()));
    if (tasks.length == 0) {
      print('There\'s no task. Congratulations! :D');
    }
  }
}

// Command Handler for Adding Task
class AddCommand extends Command {
  final name = "add";
  final description = "Adds a task into the list.";

  AddCommand();

  Future run() async{
    await openDatabaseConnection();
    await new database.Crud('todo').create({
      'text': this.argResults.arguments.join(' '),
      'checked': false
    });
    print('\nSaved!');
  }
}

class CheckCommand extends Command {
  final name = "check";
  final description = "Checks or unchecks a task.";

  CheckCommand();

  Future run() async{
    await openDatabaseConnection();
    var tasks = new database.Crud('todo');
    if (argResults.arguments.length == 0 || int.parse(argResults.arguments[0]).isNaN) {
      print('\nGimme\' and Id, you can get it by listing all your task! :)');
      exit(0);
    }
    int id = int.parse(argResults.arguments[0]);
    var task = await tasks.readOne(id);
    if(task == null) {
      print('\nUhh, this Id doesn\'t exists! :(');
      exit(0);
    }
    else {
      task = new Task.fromJson(task);
      await tasks.update(id, {
        'checked' : !task.checked
      });
      print('\nTask updated! :D');
    }

  }
}

class DeleteCommand extends Command {
  final name = "delete";
  final description = "Checks or unchecks a task.";

  DeleteCommand() {
    argParser.addFlag('all', abbr: 'a', defaultsTo:false);
  }

  Future run() async {
    bool deleteAll = argResults['all'];
    await openDatabaseConnection();
    var tasks = await new database.Crud('todo');
    if (deleteAll) {
      await tasks.deleteAll();
      print('\nDeleted All Records! :D');
    }
    else {
      if (argResults.arguments.length == 0 || int.parse(argResults.arguments[0]).isNaN) {
        print('\nGimme\' and Id, you can get it by listing all your task! :)');
        exit(0);
      }
      var result = await tasks.delete(int.parse(argResults.arguments[0]));
      print('\n' + ((result['n'] == 0) ? 'This task doesn\'t exists :(' : 'Deleted! :D'));
    }
  }
}