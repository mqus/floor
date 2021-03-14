import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';
import 'package:floor_generator/misc/extension/set_equality_extension.dart';
import 'package:floor_generator/value_object/query.dart';
import 'package:floor_generator/value_object/query_method_return_type.dart';
import 'package:floor_generator/value_object/type_converter.dart';

/// Wraps a method annotated with Query
/// to enable easy access to code generation relevant data.
class QueryMethod {
  final String name;

  /// Query where the parameter mapping is stored.
  final Query query;

  final QueryMethodReturnType returnType;

  final List<ParameterElement> parameters;

  final Set<TypeConverter> typeConverters;

  QueryMethod(
    this.name,
    this.query,
    this.parameters,
    this.returnType,
    this.typeConverters,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryMethod &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          query == other.query &&
          parameters.equals(other.parameters) &&
          returnType == other.returnType &&
          typeConverters.equals(other.typeConverters);

  @override
  int get hashCode =>
      name.hashCode ^
      query.hashCode ^
      parameters.hashCode ^
      returnType.hashCode ^
      typeConverters.hashCode;

  @override
  String toString() {
    return 'QueryMethod{name: $name, query: $query, parameters: $parameters, returnType: $returnType, typeConverters: $typeConverters}';
  }
}
