import 'package:dogs_core/dogs_core.dart';

@LinkSerializer()
class DateTimeConverter extends DogConverter<DateTime> with StructureEmitter<DateTime> {

  @override
  DateTime convertFromGraph(DogGraphValue value, DogEngine engine) {
    var str = value as DogString;
    return DateTime.parse(str.value);
  }

  @override
  DogGraphValue convertToGraph(DateTime value, DogEngine engine) {
    return DogString(value.toIso8601String());
  }

  @override
  DogStructure get structure => DogStructure.named(DateTime, "date");
}

@Serializable()
class Person with DogsMixin<Person> {

  String name;
  int age;
  Set<String>? tags;
  List<Note> notes;
  Gender gender;

  @PropertyName("birthday")
  @PropertySerializer(PolymorphicConverter)
  DateTime birthdayDate;

  Person.dog(this.name, this.age, this.tags, this.notes, this.birthdayDate, this.gender);

  Person({
    required this.name,
    required this.age,
    this.tags,
    required this.notes,
    required this.gender,
    required this.birthdayDate,
  });
}

@Serializable()
class Note with DogsMixin {
  String text;
  int id;

  @Polymorphic()
  Object? attachment;

  Note(this.text, this.id, this.attachment);
}

@Serializable()
enum Gender { male, female, other }
