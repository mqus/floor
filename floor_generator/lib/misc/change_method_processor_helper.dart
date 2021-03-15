// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/change_method_processor_error.dart';
import 'package:floor_generator/value_object/entity.dart';
import 'package:source_gen/source_gen.dart';

/// Groups common functionality of change method processors.
class ChangeMethodProcessorHelper {
  final MethodElement _methodElement;
  final List<Entity> _entities;

  final ChangeMethodProcessorError processorError;

  ChangeMethodProcessorHelper(
    final MethodElement methodElement,
    final List<Entity> entities,
  )   : _methodElement = methodElement,
        _entities = entities,
        processorError = ChangeMethodProcessorError(methodElement);

  ParameterElement getParameterElement() {
    final parameters = _methodElement.parameters;
    if (parameters.isEmpty) {
      throw InvalidGenerationSourceError(
        'There is no parameter supplied for this method. Please add one.',
        element: _methodElement,
      );
    } else if (parameters.length > 1) {
      throw InvalidGenerationSourceError(
        'Only one parameter is allowed on this.',
        element: _methodElement,
      );
    }
    return parameters.first;
  }

  DartType _getFlattenedParameterType(
    final ParameterElement parameterElement,
  ) {
    final changesMultipleItems = parameterElement.type.isDartCoreList;

    return changesMultipleItems
        ? parameterElement.type.flatten()
        : parameterElement.type;
  }

  Entity getEntity(final ParameterElement parameterElement) {
    final flattenedParameterType = _getFlattenedParameterType(parameterElement);
    return _entities.firstWhere(
        (entity) =>
            entity.classElement.displayName ==
            flattenedParameterType.getDisplayString(withNullability: false),
        orElse: () => throw InvalidGenerationSourceError(
            'You are trying to change an object which is not an entity.',
            element: _methodElement));
  }

  DartType getFlattenedReturnType() {
    return _methodElement.library.typeSystem.flatten(_methodElement.returnType);
  }

  void assertMethodReturnsFuture(String methodType) {
    if (!_methodElement.returnType.isDartAsyncFuture) {
      throw processorError.changeMustReturnIntOrVoidFuture(methodType);
    }
  }

  void assertMethodReturnsIntOrVoid(String methodType, final DartType flat) {
    if (!flat.isVoid && !flat.isDartCoreInt) {
      throw processorError.changeMustReturnIntOrVoidFuture(methodType);
    }
  }
}
