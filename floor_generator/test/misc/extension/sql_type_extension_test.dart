import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/sql_type_extension.dart';
import 'package:sqlparser/sqlparser.dart';
import 'package:test/test.dart';

void main() {
  group('convert string to basicType', () {
    test('text',
        () => expect(SqlType.text.toBasicType(), equals(BasicType.text)));
    test('integer',
        () => expect(SqlType.integer.toBasicType(), equals(BasicType.int)));
    test('real',
        () => expect(SqlType.real.toBasicType(), equals(BasicType.real)));
    test('blob',
        () => expect(SqlType.blob.toBasicType(), equals(BasicType.blob)));
    test('throws on arbitrary string',
        () => expect(() => ''.toBasicType(), throwsArgumentError));
  });
}
