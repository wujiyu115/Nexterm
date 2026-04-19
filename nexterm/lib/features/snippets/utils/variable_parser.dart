class VariableParser {
  static final _variablePattern = RegExp(r'\$\{(\w+)\}');

  static List<String> extractVariables(String command) {
    final matches = _variablePattern.allMatches(command);
    final seen = <String>{};
    final result = <String>[];
    for (final match in matches) {
      final name = match.group(1)!;
      if (seen.add(name)) result.add(name);
    }
    return result;
  }

  static String substitute(String command, Map<String, String> values) {
    return command.replaceAllMapped(_variablePattern, (match) {
      final name = match.group(1)!;
      return values.containsKey(name) ? values[name]! : match.group(0)!;
    });
  }

  static List<String> splitLines(String command) {
    return command.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
  }
}
