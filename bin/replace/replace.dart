typedef ReplaceFunction = String Function(Match);

class FindReplaceDefinition {
  FindReplaceDefinition._({
    required this.find,
    required this.replace,
  });

  factory FindReplaceDefinition({
    required String findPattern,
    required String replacePattern,
  }) =>
      FindReplaceDefinition._(
        find: RegExp(findPattern, multiLine: true),
        replace: (Match matches) => applyMatchesToReplacePattern(replacePattern, matches),
      );

  final RegExp find;
  final ReplaceFunction replace;

  String execute(String content) => content.replaceAllMapped(find, replace);

  static String applyMatchesToReplacePattern(String replacePattern, Match matches) {
    for (int i = 1; i <= matches.groupCount; i++) {
      replacePattern = replacePattern.replaceAll("\$$i", matches.group(i - 1) ?? "");
    }
    return replacePattern;
  }
}

final notionFindReplaceDefinitions = <FindReplaceDefinition>[
  FindReplaceDefinition(
      findPattern: r'(^[^#@\n].+\s\{)',
      replacePattern: r'#notion $1'), // restrict styling to #notion div
  FindReplaceDefinition(
      findPattern: r'(^[^#@\n].+,$)',
      replacePattern: r'#notion $1'), // restrict styling to #notion div
  FindReplaceDefinition(
      findPattern: r'<body>((.|\n)*)</body>',
      replacePattern: r'<body><div id="notion">$1</div></body>'), // wrap body in #notion div
  FindReplaceDefinition(
      findPattern: r'\/\* cspell:disable-file \*\/',
      replacePattern:
          r'* {} body { background-color: #fff; overflow-x: scroll;} body * { color: #000; }'), // custom styling
  FindReplaceDefinition(
      findPattern: r'<details open="">', replacePattern: r'<details>'), // close toggles
];

String findAndReplaceOnString(String content, List<FindReplaceDefinition> definitions) {
  for (final definition in definitions) {
    content = definition.execute(content);
  }
  return content;
}
