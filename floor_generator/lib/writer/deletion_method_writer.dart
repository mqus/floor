// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:code_builder/code_builder.dart';
import 'package:floor_generator/misc/change_method_writer_helper.dart';
import 'package:floor_generator/misc/extension/string_extension.dart';
import 'package:floor_generator/value_object/deletion_method.dart';
import 'package:floor_generator/writer/writer.dart';

class DeletionMethodWriter implements Writer {
  final DeletionMethod _method;
  final ChangeMethodWriterHelper _helper;

  DeletionMethodWriter(
    final DeletionMethod method, [
    final ChangeMethodWriterHelper? helper,
  ])  : _method = method,
        _helper = helper ?? ChangeMethodWriterHelper(method);

  @override
  Method write() {
    final methodBuilder = MethodBuilder()..body = Code(_generateMethodBody());
    _helper.addChangeMethodSignature(methodBuilder);
    return methodBuilder.build();
  }

  String _generateMethodBody() {
    final entityClassName =
        _method.entity.className.decapitalize();
    final methodSignatureParameterName = _method.parameterElement.name;

    final list = _method.changesMultipleItems ? 'List' : '';

    if (_method.returnsVoid) {
      return 'await _${entityClassName}DeletionAdapter'
          '.delete$list($methodSignatureParameterName);';
    } else {
      // if not void then must be int return
      return 'return _${entityClassName}DeletionAdapter'
          '.delete${list}AndReturnChangedRows($methodSignatureParameterName);';
    }
  }
}
