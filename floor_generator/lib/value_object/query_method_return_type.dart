import 'package:floor_generator/misc/type_utils.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/queryable.dart';

/// A simple accessor class for providing all properties of
/// the return type of a query method
class QueryMethodReturnType {
  final DartType raw;

  late Queryable? queryable;

  // the following attributes are derived on construction and stored.
  final bool isStream;
  final bool isFuture;
  final bool isList;

  /// Flattened return type
  ///
  /// E.g.
  /// Future<T> -> T
  /// Stream<List<T>> -> T
  final DartType flat;

  bool get isVoid => flat.isVoid;
  bool get isPrimitive =>
      flat.isVoid ||
      flat.isDartCoreDouble ||
      flat.isDartCoreInt ||
      flat.isDartCoreBool ||
      flat.isDartCoreString ||
      flat.isUint8List;

  QueryMethodReturnType(this.raw)
      : isStream = raw.isStream,
        isFuture = raw.isDartAsyncFuture,
        isList = raw.flatten().isDartCoreList,
        flat = _flattenWithList(raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryMethodReturnType &&
          runtimeType == other.runtimeType &&
          raw == other.raw &&
          queryable == other.queryable;

  @override
  int get hashCode => raw.hashCode ^ queryable.hashCode;

  @override
  String toString() {
    return 'QueryMethodReturnType{raw: $raw, flat: $flat, queryable: $queryable}';
  }

  static DartType _flattenWithList(DartType raw) {
    final flattenedOnce = raw.flatten();
    if (flattenedOnce.isDartCoreList) {
      return flattenedOnce.flatten();
    } else {
      return flattenedOnce;
    }
  }
}
