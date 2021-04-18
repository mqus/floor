import 'package:analyzer/dart/element/element.dart';
import 'package:floor_annotation/floor_annotation.dart' as annotations;
import 'package:floor_generator/misc/constants.dart';
import 'package:floor_generator/misc/type_utils.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/query_analyzer/engine.dart';
import 'package:floor_generator/processor/queryable_processor.dart';
import 'package:floor_generator/value_object/field.dart';
import 'package:floor_generator/value_object/type_converter.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:sqlparser/sqlparser.dart' as sqlparser;

class ViewProcessor extends QueryableProcessor<View> {
  final ViewProcessorError _processorError;
  final AnalyzerEngine _analyzerContext;

  ViewProcessor(
    final ClassElement classElement,
    final Set<TypeConverter> typeConverters,
    this._analyzerContext,
  )   : _processorError = ViewProcessorError(classElement),
        super(classElement, typeConverters);

  @override
  View process() {
    final fields = getFields();
    final name = _getName();
    final query = _getQuery();

    final sqlParserView = _checkAndConvert(query, name, fields);

    final floorView = View(
      classElement,
      name,
      fields,
      query,
      getConstructor(fields),
    );
    _analyzerContext.registerView(floorView, sqlParserView);
    return floorView;
  }

  String _getName() {
    return classElement
            .getAnnotation(annotations.DatabaseView)
            ?.getField(AnnotationField.viewName)
            ?.toStringValue() ??
        classElement.displayName;
  }

  String _getQuery() {
    final query = classElement
        .getAnnotation(annotations.DatabaseView)
        ?.getField(AnnotationField.viewQuery)
        ?.toStringValue();

    return query ?? (throw _processorError.missingQuery);
  }

  sqlparser.View _checkAndConvert(
      String query, String name, List<Field> fields) {
    final parserCtx = _analyzerContext.inner.parse(query);

    if (parserCtx.errors.isNotEmpty) {
      throw _processorError.parseErrorFromSqlparser(parserCtx.errors.first);
    }

    if (!(parserCtx.rootNode is sqlparser.BaseSelectStatement)) {
      throw _processorError.missingQuery;
    }

    //analyze query (derive types)
    final ctx = _analyzerContext.inner.analyzeParsed(parserCtx);
    if (ctx.errors.isNotEmpty) {
      throw _processorError.analysisErrorFromSqlparser(ctx.errors.first);
    }

    final viewStmt = sqlparser.CreateViewStatement(
      ifNotExists: true,
      viewName: name,
      columns: fields.map((f) => f.columnName).toList(growable: false),
      query: ctx.root as sqlparser.BaseSelectStatement,
    );

    sqlparser.LintingVisitor(getDefaultEngineOptions(), ctx)
        .visitCreateViewStatement(viewStmt, null);
    if (ctx.errors.isNotEmpty) {
      throw _processorError.lintingErrorFromSqlparser(ctx.errors.first);
    }

    return const sqlparser.SchemaFromCreateTable(moorExtensions: false)
        .readView(ctx, viewStmt);
  }
}
