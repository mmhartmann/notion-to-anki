import 'dart:math';

String replaceImageNames(String content, List<String> imageNames) {
  final imagePathPattern = RegExp(r'(?<=src=")([^\/]*\/*(?=Untitled)[^"]*)', multiLine: true);

  final pathMatches = imagePathPattern.allMatches(content);

  if (imageNames.length < pathMatches.length) {
    print("WARNING: Not enough image paths provided, images will be left empty");
  }

  for (int i = 0; i < min(imageNames.length, pathMatches.length); i++) {
    content = content.replaceAll(pathMatches.elementAt(i).group(0) ?? "", imageNames[i]);
  }

  return content;
}
