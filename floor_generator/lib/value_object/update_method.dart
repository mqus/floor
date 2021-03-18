import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/change_method.dart';
import 'package:floor_generator/value_object/entity.dart';

class UpdateMethod extends ChangeMethod {
  final String onConflict;

  UpdateMethod(
    final String name,
    final DartType returnType,
    final bool returnsVoid,
    final ParameterElement parameterElement,
    final Entity entity,
    this.onConflict,
  ) : super(
          name,
          returnType,
          returnsVoid,
          parameterElement,
          entity,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is UpdateMethod &&
          runtimeType == other.runtimeType &&
          onConflict == other.onConflict;

  @override
  int get hashCode => super.hashCode ^ onConflict.hashCode;

  @override
  String toString() {
    return 'UpdateMethod{name: $name, returnType: $returnType, returnsVoid: $returnsVoid, parameterElement: $parameterElement, entity: $entity, onConflict: $onConflict}';
  }
}
