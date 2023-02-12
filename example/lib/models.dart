import 'package:dogs_core/dogs_core.dart';

@Serializable()
@ApiDescription("A random unique person")
class Person with DogsMixin<Person> {

  @ApiDescription("The name of the person")
  @LengthRange(min: 1, max: 128)
  String name;
  @Range(min: 0, max: 130)
  int age;
  @LengthRange(max: 64)
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
@TestStructureAnnotation("Note Outer")
class Note with DogsMixin {
  String text;

  @TestStructureAnnotation("Note Inner")
  int id;

  @Polymorphic()
  Object? attachment;

  Note(this.text, this.id, this.attachment);
}

@Serializable()
enum Gender { male, female, other }
