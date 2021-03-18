import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/value_object/change_method.dart';
import 'package:floor_generator/value_object/entity.dart';

class DeletionMethod extends ChangeMethod {
  DeletionMethod(
    final String name,
    final DartType returnType,
    final bool returnsVoid,
    final ParameterElement parameterElement,
    final Entity entity,
  ) : super(
          name,
          returnType,
          returnsVoid,
          parameterElement,
          entity,
        );

  @override
  String toString() {
    return 'DeletionMethod{name: $name, returnType: $returnType, returnsVoid: $returnsVoid, parameterElement: $parameterElement, entity: $entity}';
  }
}
