import 'package:analyzer/dart/element/element.dart';
import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqlparser/sqlparser.dart';

class ViewProcessorError {
  final ClassElement _classElement;

  ViewProcessorError(final ClassElement classElement)
      : _classElement = classElement;

  InvalidGenerationSourceError get missingQuery {
    return InvalidGenerationSourceError(
      'There is no SELECT query defined on the database view ${_classElement.displayName}.',
      todo:
          'Define a SELECT query for this database view with @DatabaseView(\'SELECT [...]\') ',
      element: _classElement,
    );
  }

  ProcessorError parseErrorFromSqlparser(ParsingError parsingError) {
    return ProcessorError(
        message:
            'The following error occurred while parsing the SQL-Statement in ${_classElement.displayName}: ${parsingError.toString()}',
        todo: '',
        element: _classElement);
  }

  ProcessorError analysisErrorFromSqlparser(AnalysisError lintingError) {
    return ProcessorError(
        message:
            'The following error occurred while analyzing the SQL-Statement in ${_classElement.displayName}: ${lintingError.toString()}',
        todo: '',
        element: _classElement);
  }

  ProcessorError lintingErrorFromSqlparser(AnalysisError lintingError) {
    return ProcessorError(
        message:
            'The following error occurred while comparing the DatabaseView to the SQL-Statement in ${_classElement.displayName}: ${lintingError.toString()}',
        todo: '',
        element: _classElement);
  }
}
