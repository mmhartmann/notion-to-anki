import 'dart:io';

import 'package:args/args.dart';

import 'replace/replace.dart';
import 'replace/replace_image_names.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addOption('file', abbr: 'f', help: 'The file that should be converted.', mandatory: true)
    ..addOption('images',
        abbr: 'i', help: 'Comma-separated list of filenames of the images that should be replaced')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage information.')
    ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Show additional command output.')
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart notion_to_anki.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) async {
  Console.init();

  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('notion_to_anki version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    String filename = results['file'];
    List<String> imageNames = results['images']?.split(",") ?? [];

    await processFile(filename, imageNames);

    // Act on the arguments provided.
    if (verbose) {
      print('Positional arguments: ${results.rest}');
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e);
    print('');
    printUsage(argParser);
  }
}

Future<void> processFile(String filename, List<String> imageNames) async {
  var content = await File(filename).readAsString();
  content = findAndReplaceOnString(content, notionFindReplaceDefinitions);
  content = replaceImageNames(content, imageNames);
  await File("$filename-converted.html").writeAsString(content);
}
