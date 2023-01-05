import 'package:dogs/dogs.dart';

@LinkSerializer()
class DateTimeConverter extends DogConverter<DateTime> {
  @override
  DateTime convertFromGraph(DogGraphValue value, DogEngine engine) {
    var str = value as DogString;
    return DateTime.parse(str.value);
  }

  @override
  DogGraphValue convertToGraph(DateTime value, DogEngine engine) {
    return DogString(value.toIso8601String());
  }
}

@Serializable()
class Person with DogsMixin {

  String name;
  int age;
  Set<String>? tags;
  List<Note> notes;
  Gender gender;

  @PropertyName("birthday")
  DateTime birthdayDate;

  Person(this.name, this.age, this.tags, this.notes, this.birthdayDate, this.gender);

}

@Serializable()
class Note with DogsMixin {
  String text;
  int id;

  Note(this.text, this.id);
}

@Serializable()
enum Gender { male, female, other }
