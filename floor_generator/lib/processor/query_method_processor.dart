import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/extension/dart_type_extension.dart';
import 'package:floor_generator/misc/extension/iterable_extension.dart';
import 'package:floor_generator/misc/extension/set_extension.dart';
import 'package:floor_generator/misc/extension/type_converter_element_extension.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/query_method_processor_error.dart';
import 'package:floor_generator/processor/processor.dart';
import 'package:floor_generator/processor/query_processor.dart';
import 'package:floor_generator/value_object/query_method.dart';
import 'package:floor_generator/value_object/query_method_return_type.dart';
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/value_object/type_converter.dart';

class QueryMethodProcessor extends Processor<QueryMethod> {
  final QueryMethodProcessorError _processorError;

  final MethodElement _methodElement;
  final List<Queryable> _queryables;
  final Set<TypeConverter> _typeConverters;

  QueryMethodProcessor(
    final MethodElement methodElement,
    final List<Queryable> queryables,
    final Set<TypeConverter> typeConverters,
  )   : _methodElement = methodElement,
        _queryables = queryables,
        _typeConverters = typeConverters,
        _processorError = QueryMethodProcessorError(methodElement);

  @override
  QueryMethod process() {
    final name = _methodElement.displayName;
    final parameters = _methodElement.parameters;
    final returnType = _getAndCheckReturnType();

    final query = QueryProcessor(_methodElement, _getQuery()).process();

    final parameterTypeConverters = parameters
        .expand((parameter) =>
            parameter.getTypeConverters(TypeConverterScope.daoMethodParameter))
        .toSet();

    final allTypeConverters = _typeConverters +
        _methodElement.getTypeConverters(TypeConverterScope.daoMethod) +
        parameterTypeConverters;

    if (returnType.queryable != null) {
      final fieldTypeConverters = returnType.queryable!.fields
          .mapNotNull((field) => field.typeConverter);
      allTypeConverters.addAll(fieldTypeConverters);
    }

    return QueryMethod(
      name,
      query,
      parameters,
      returnType,
      allTypeConverters,
    );
  }

  String _getQuery() {
    final query = _methodElement
        .getAnnotation(annotations.Query)
        .getField(AnnotationField.queryValue)
        ?.toStringValue()
        ?.trim();

    if (query == null || query.isEmpty) throw _processorError.noQueryDefined;
    return query;
  }

  void _assertReturnsFutureOrStream(final DartType rawType) {
    if (!rawType.isDartAsyncFuture && !rawType.isStream) {
      throw _processorError.doesNotReturnFutureNorStream;
    }
  }

  void _assertReturnsNullableSingle(QueryMethodReturnType returnType) {
    if (!returnType.isList &&
        !returnType.isVoid &&
        !returnType.flat.isNullable) {
      if (returnType.isStream) {
        throw _processorError.doesNotReturnNullableStream;
      } else {
        throw _processorError.doesNotReturnNullableFuture;
      }
    }
  }

  void _assertReturnsFutureOnVoid(QueryMethodReturnType returnType) {
    if (returnType.isVoid && (returnType.isStream || returnType.isList)) {
      throw _processorError.doesNotReturnFutureVoid;
    }
  }

  QueryMethodReturnType _getAndCheckReturnType() {
    _assertReturnsFutureOrStream(_methodElement.returnType);

    final type = QueryMethodReturnType(_methodElement.returnType);

    _assertReturnsNullableSingle(type);
    _assertReturnsFutureOnVoid(type);

    type.queryable = _queryables.firstWhereOrNull((queryable) =>
        queryable.classElement.displayName ==
        type.flat.getDisplayString(withNullability: false));

    return type;
  }
}
