// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Update, OnConflictStrategy;
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_object_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/update_method.dart';
import 'package:source_gen/source_gen.dart';

class UpdateMethodProcessor implements Processor<UpdateMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;

  UpdateMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper? changeMethodProcessorHelper,
  ])  : _methodElement = methodElement,
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @override
  UpdateMethod process() {
    _helper.assertMethodReturnsFuture('Update');

    final flattenedReturnType = _helper.getFlattenedReturnType();

    _helper.assertMethodReturnsIntOrVoid('Update', flattenedReturnType);

    final parameterElement = _helper.getParameterElement();
    final entity = _helper.getEntity(parameterElement);
    final onConflict = _getOnConflictStrategy();

    return UpdateMethod(
      _methodElement.name,
      _methodElement.returnType,
      flattenedReturnType.isVoid,
      parameterElement,
      entity,
      onConflict,
    );
  }

  String _getOnConflictStrategy() {
    final onConflictStrategy = _methodElement
        .getAnnotation(annotations.Update)
        .getField(AnnotationField.onConflict)
        ?.toEnumValueString();

    if (onConflictStrategy == null) {
      throw InvalidGenerationSourceError(
        'Value of ${AnnotationField.onConflict} must be one of ${annotations.OnConflictStrategy.values.map((e) => e.toString()).join(',')}',
        element: _methodElement,
      );
    } else {
      return onConflictStrategy;
    }
  }
}
