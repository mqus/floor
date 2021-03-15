// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations
    show Insert, OnConflictStrategy;
import 'package:floor_generator/misc/change_method_processor_helper.dart';
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_object_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/insertion_method.dart';
import 'package:source_gen/source_gen.dart';

class InsertionMethodProcessor implements Processor<InsertionMethod> {
  final MethodElement _methodElement;
  final ChangeMethodProcessorHelper _helper;

  InsertionMethodProcessor(
    final MethodElement methodElement,
    final List<Entity> entities, [
    final ChangeMethodProcessorHelper? changeMethodProcessorHelper,
  ])  : _methodElement = methodElement,
        _helper = changeMethodProcessorHelper ??
            ChangeMethodProcessorHelper(methodElement, entities);

  @override
  InsertionMethod process() {
    _assertMethodReturnsFuture();

    final flattenedReturnType = _getAndCheckFlatReturnType();

    final parameterElement = _helper.getParameterElement();
    final entity = _helper.getEntity(parameterElement);
    final onConflict = _getOnConflictStrategy();

    return InsertionMethod(
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
        .getAnnotation(annotations.Insert)
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

  void _assertMethodReturnsFuture() {
    if (!_methodElement.returnType.isDartAsyncFuture) {
      throw _helper.processorError.insertMustReturnIntOrVoidFutureList;
    }
  }

  DartType _getAndCheckFlatReturnType() {
    DartType flattened = _helper.getFlattenedReturnType();
    if (flattened.isVoid || flattened.isDartCoreInt) {
      return flattened;
    }
    if (flattened.isDartCoreList) {
      flattened = flattened.flatten();
      if (flattened.isDartCoreInt) {
        return flattened;
      }
    }
    throw _helper.processorError.insertMustReturnIntOrVoidFutureList;
  }
}
