import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/entity.dart';

/// Base class for change methods (insert, update, delete).
class ChangeMethod {
  final String name;
  final DartType returnType;
  final bool returnsVoid;
  final ParameterElement parameterElement;
  final Entity entity;

  ChangeMethod(
    this.name,
    this.returnType,
    this.returnsVoid,
    this.parameterElement,
    this.entity,
  );

  bool get requiresAsyncModifier => returnsVoid;

  bool get changesMultipleItems => parameterElement.type.isDartCoreList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeMethod &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          returnType == other.returnType &&
          returnsVoid == other.returnsVoid &&
          parameterElement == other.parameterElement &&
          entity == other.entity;

  @override
  int get hashCode =>
      name.hashCode ^
      returnType.hashCode ^
      returnsVoid.hashCode ^
      parameterElement.hashCode ^
      entity.hashCode;
}
