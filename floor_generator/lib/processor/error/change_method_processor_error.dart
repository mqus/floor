import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';

class ChangeMethodProcessorError {
  final MethodElement _methodElement;

  const ChangeMethodProcessorError(final MethodElement methodElement)
      : _methodElement = methodElement;

  ProcessorError changeMustReturnIntOrVoidFuture(String type) {
    return ProcessorError(
      message: '$type methods have to return a Future of either void or int.',
      todo:
          'Give the method a return type of either `Future<void>` or `Future<int>`.',
      element: _methodElement,
    );
  }

  ProcessorError get insertMustReturnIntOrVoidFutureList {
    return ProcessorError(
      message:
          'Insertion methods have to return a Future of either void or int or List<int>.',
      todo:
          'Give the method a return type of either `Future<void>`, `Future<int>` or `Future<List<int>>`.',
      element: _methodElement,
    );
  }
}
