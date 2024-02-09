String? extractTitle(String content) {
  final titleRegex = RegExp("<title>(.*)<\/title>", multiLine: true);
  return titleRegex.firstMatch(content)?.group(1);
}
