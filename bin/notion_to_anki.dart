import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_clipboard/dart_clipboard.dart';

import 'find/extract_title.dart';
import 'replace/replace.dart';
import 'replace/replace_image_names.dart';

const String version = '0.0.1';
const String listDivider = ':';

ArgParser buildParser() {
  return ArgParser()
    ..addOption('images',
        abbr: 'i', help: 'Comma-separated list of filenames of the images that should be replaced.')
    ..addFlag('wait',
        abbr: 'w',
        negatable: false,
        help: 'Wait after processing each file until you press <ENTER>.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage information.')
    ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Show additional command output.')
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart notion_to_anki.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;
    bool wait = results.wasParsed('wait');

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

    List<String> imageNames = results['images']?.split(listDivider) ?? [];
    List<String> filenames = results.rest;

    for (int i = 0; i < filenames.length; i++) {
      await processFile(filenames[i], imageNames);

      if (i < filenames.length - 1 && wait) {
        stdin.readLineSync();
      }
    }

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
  final title = extractTitle(content);
  await File("$filename-converted.html").writeAsString(content);

  print("File \"$title\" converted (Copied to clipboard)");
  // Clipboard.setContents(content);
}
