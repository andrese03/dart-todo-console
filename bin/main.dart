// Task console application
import 'package:args/command_runner.dart';
import 'package:recogeme_practica_2/commands.dart';

import 'package:recogeme_practica_2/crud.dart';

main (List<String> args) async {
  var runner = new CommandRunner("todo", "Distributed version control.")
    ..addCommand(new AddCommand())
    ..addCommand(new ListCommand())
    ..addCommand(new CheckCommand())
    ..addCommand(new DeleteCommand());

  runner.run(args)
    .then(commandLineClose)
    .catchError(commandLineErrorHandler);
}
