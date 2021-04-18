import 'package:floor_generator/value_object/entity.dart';
import 'package:floor_generator/value_object/view.dart' as floor;
import 'package:floor_generator/value_object/queryable.dart';
import 'package:floor_generator/misc/extension/sql_type_extension.dart';
import 'package:sqlparser/sqlparser.dart' hide Queryable;

EngineOptions getDefaultEngineOptions() => EngineOptions(
      useMoorExtensions: false,
      enabledExtensions: const [],
    );

//possibilities to expand the usage:
// - variable detection (matching in queries, asserting that no variable exists in views)
// - depencency resolution queries/views
// - type matching (providing input, checking output)
// - arbitrary query returns
class AnalyzerEngine {
  final Map<String, Queryable> registry = {};

  final SqlEngine inner = SqlEngine(getDefaultEngineOptions());

  AnalyzerEngine();

  void registerEntity(Entity e) {
    inner.registerTable(Table(
      name: e.name,
      resolvedColumns: e.fields
          .map((field) => TableColumn(
              field.columnName,
              ResolvedType(
                  type: field.sqlType.toBasicType(),
                  nullable: field.isNullable,
                  hint: field.fieldElement.type.isDartCoreBool
                      ? const IsBoolean()
                      : null)))
          .toList(growable: false),
      withoutRowId: e.withoutRowid,
    ));
    registry[e.name] = e;
  }

  void registerView(floor.View floorView, View convertedView) {
    inner.registerView(convertedView);
    registry[floorView.name] = floorView;
  }
}
