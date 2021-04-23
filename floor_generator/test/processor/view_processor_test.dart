import 'package:floor_generator/processor/error/processor_error.dart';
import 'package:floor_generator/processor/error/view_processor_error.dart';
import 'package:floor_generator/processor/field_processor.dart';
import 'package:floor_generator/processor/view_processor.dart';
import 'package:floor_generator/value_object/view.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('Process view', () async {
    final classElement = await createClassElement('''
      @DatabaseView("SELECT * from Person")
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    const name = 'PersonView';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    const query = 'SELECT * from Person';
    const constructor = "PersonView(row['id'] as int, row['name'] as String)";
    final expected = View(
      classElement,
      name,
      fields,
      query,
      constructor,
    );
    expect(actual, equals(expected));
  });

  test('Process view starting with WITH statement', () async {
    final classElement = await createClassElement('''
      @DatabaseView("WITH subquery as (SELECT * from Person) SELECT subquery.*")
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    const name = 'PersonView';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    const query = 'WITH subquery as (SELECT * from Person) SELECT subquery.*';
    const constructor = "PersonView(row['id'] as int, row['name'] as String)";
    final expected = View(
      classElement,
      name,
      fields,
      query,
      constructor,
    );
    expect(actual, equals(expected));
  });
  test('Throws when view annotation is invalid', () async {
    final classElement = await createClassElement('''
      @DatabaseView(1)
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual = () async =>
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    expect(
        actual,
        throwsInvalidGenerationSourceError(
            ViewProcessorError(classElement).missingQuery));
  });

  test('Throws when processing view without SELECT', () async {
    final classElement = await createClassElement('''
      @DatabaseView('DELETE FROM Person')
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual = () async =>
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    expect(
        actual,
        throwsInvalidGenerationSourceError(
            ViewProcessorError(classElement).missingQuery));
  });

  test(
      'Throws when processing view starting with WITH statement without SELECT',
      () async {
    final classElement = await createClassElement('''
      @DatabaseView("WITH subquery")
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual = () async =>
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    expect(actual, throwsProcessorError());
  });

  test(
      'Throws when processing view starting with WITH statement with only one SELECT',
      () async {
    final classElement = await createClassElement('''
      @DatabaseView("WITH subquery as (SELECT * from Person)")
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual = () async =>
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    expect(actual, throwsProcessorError());
  });
  test('Process view with mutliline query', () async {
    final classElement = await createClassElement("""
      @DatabaseView('''
        SELECT * 
        from Person
      ''')
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    """);

    final actual =
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process()
            .query;

    const expected = '''
        SELECT * 
        from Person
      ''';
    expect(actual, equals(expected));
  });

  test('Process view with concatenated string query', () async {
    final classElement = await createClassElement('''
      @DatabaseView('SELECT * ' 
          'from Person')
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process()
            .query;

    const expected = 'SELECT * from Person';
    expect(actual, equals(expected));
  });

  test('Process view with dedicated name', () async {
    final classElement = await createClassElement('''
      @DatabaseView("SELECT * from Person",viewName: "personview")
      class PersonView {
        final int id;
      
        final String name;
      
        PersonView(this.id, this.name);
      }
    ''');

    final actual =
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();

    const name = 'personview';
    final fields = classElement.fields
        .map((fieldElement) => FieldProcessor(fieldElement, null).process())
        .toList();
    const query = 'SELECT * from Person';
    const constructor = "PersonView(row['id'] as int, row['name'] as String)";
    final expected = View(
      classElement,
      name,
      fields,
      query,
      constructor,
    );
    expect(actual, equals(expected));
  });

  group('Expecting errors:', () {
    test('Wrong syntax in annotation', () async {
      final classElement = await createClassElement('''
      @DatabaseView('SELECT *, (wrong_column from Person)', viewName: 'personview')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = () async {
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsProcessorErrorWithMessagePrefix(ProcessorError(
              message:
                  'The following error occurred while parsing the SQL-Statement in ',
              todo: '',
              element: classElement)));
    });

    test('Wrong column reference in annotation', () async {
      final classElement = await createClassElement('''
      @DatabaseView('SELECT *, wrong_column from Person', viewName: 'personview')
      class Person {
        final int id;
      
        final String name;
      
        Person(this.id, this.name);
      }
    ''');

      final actual = () async {
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsProcessorErrorWithMessagePrefix(ProcessorError(
              message:
                  'The following error occurred while analyzing the SQL-Statement in ',
              todo: '',
              element: classElement)));
    });

    test('Column mismatch', () async {
      final classElement = await createClassElement('''
        @DatabaseView('SELECT id from Person', viewName: 'personview')
        class Person {
          final int id;
        
          final String name;
        
          Person(this.id, this.name);
        }
      ''');

      final actual = () async {
        ViewProcessor(classElement, {}, await getEngineWithPersonEntity())
            .process();
      };

      expect(
          actual,
          throwsProcessorErrorWithMessagePrefix(ProcessorError(
              message:
                  'The following error occurred while comparing the DatabaseView to the SQL-Statement in ',
              todo: '',
              element: classElement)));
    });
  });
}
