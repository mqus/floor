import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/annotation_expression.dart';
import 'package:floor_generator/value_object/transaction_method.dart';
import 'package:floor_generator/writer/writer.dart';
import 'package:floor_generator/misc/type_utils.dart';

class TransactionMethodWriter implements Writer {
  final TransactionMethod method;

  TransactionMethodWriter(final this.method);

  @override
  Method write() {
    return Method((builder) => builder
      ..annotations.add(overrideAnnotationExpression)
      ..returns = refer(method.returnType.getDisplayString())
      ..name = method.name
      ..requiredParameters.addAll(_generateParameters())
      ..modifier = MethodModifier.async
      ..body = Code(_generateMethodBody()));
  }

  String _generateMethodBody() {
    final parameters =
        method.parameterElements.map((parameter) => parameter.name).join(', ');
    final methodCall = '${method.name}($parameters)';
    final innerType = method.returnType.flatten();
    final ret = innerType.isVoid ? '' : 'return ';

    return '''
    if (database is sqflite.Transaction) {
      ${ret}await super.$methodCall;
    } else {
      ${ret}await (database as sqflite.Database).transaction<${innerType.toString()}>((transaction) async {
        final transactionDatabase = _\$${method.databaseName}(changeListener)..database = transaction;
        ${ret}await transactionDatabase.${method.daoFieldName}.$methodCall;
      });
    }
    ''';
  }

  List<Parameter> _generateParameters() {
    return method.parameterElements.map((parameter) {
      return Parameter((builder) => builder
        ..name = parameter.name
        ..type = refer(parameter.type.getDisplayString()));
    }).toList();
  }
}
