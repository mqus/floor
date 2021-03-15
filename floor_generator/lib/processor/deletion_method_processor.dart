// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/value_object/entity.dart';

class DeletionMethodProcessor implements Processor<DeletionMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;

  DeletionMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper? changeMethodProcessorHelper,
  ])  : _methodElement = methodElement,
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @override
  DeletionMethod process() {
    _helper.assertMethodReturnsFuture('Deletion');

    final flattenedReturnType = _helper.getFlattenedReturnType();

    _helper.assertMethodReturnsIntOrVoid('Deletion', flattenedReturnType);

    final parameterElement = _helper.getParameterElement();
    final entity = _helper.getEntity(parameterElement);

    return DeletionMethod(
      _methodElement.name,
      _methodElement.returnType,
      flattenedReturnType.isVoid,
      parameterElement,
      entity,
    );
  }
}
