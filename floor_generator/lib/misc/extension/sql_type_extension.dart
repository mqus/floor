import 'package:floor_generator/misc/constants.dart';
import 'package:sqlparser/sqlparser.dart';

extension SqlTypeExtension on String {
  BasicType toBasicType() {
    switch (this) {
      case SqlType.blob:
        return BasicType.blob;
      case SqlType.integer:
        return BasicType.int;
      case SqlType.real:
        return BasicType.real;
      case SqlType.text:
        return BasicType.text;
      default:
        throw ArgumentError("Cannot convert '$this' to `BasicType`");
    }
  }
}
