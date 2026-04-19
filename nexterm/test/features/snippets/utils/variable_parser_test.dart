import 'package:flutter_test/flutter_test.dart';
import 'package:nexterm/features/snippets/utils/variable_parser.dart';

void main() {
  group('extractVariables', () {
    test('extracts single variable', () {
      expect(VariableParser.extractVariables('echo \${name}'), equals(['name']));
    });
    test('extracts multiple variables', () {
      expect(VariableParser.extractVariables('pg_dump -U \${user} \${db} > \${file}'), equals(['user', 'db', 'file']));
    });
    test('returns empty list for no variables', () {
      expect(VariableParser.extractVariables('ls -la'), isEmpty);
    });
    test('deduplicates repeated variables', () {
      expect(VariableParser.extractVariables('\${x} and \${x} again'), equals(['x']));
    });
  });

  group('substituteVariables', () {
    test('replaces variables with values', () {
      expect(VariableParser.substitute('pg_dump -U \${user} \${db}', {'user': 'admin', 'db': 'mydb'}), equals('pg_dump -U admin mydb'));
    });
    test('leaves unknown variables unchanged', () {
      expect(VariableParser.substitute('echo \${unknown}', {}), equals('echo \${unknown}'));
    });
    test('handles empty values', () {
      expect(VariableParser.substitute('cmd \${arg}', {'arg': ''}), equals('cmd '));
    });
  });

  group('splitMultilineCommand', () {
    test('splits by newlines', () {
      expect(VariableParser.splitLines('cd /app\nls -la\npwd'), equals(['cd /app', 'ls -la', 'pwd']));
    });
    test('handles single line', () {
      expect(VariableParser.splitLines('ls'), equals(['ls']));
    });
    test('strips empty lines', () {
      expect(VariableParser.splitLines('a\n\nb\n\n'), equals(['a', 'b']));
    });
  });
}
