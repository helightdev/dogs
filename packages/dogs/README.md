<h1 align="left">
    Dart Object Graphs
    <a href="https://discord.gg/6HKuGSzYKJ">
        <img src="https://img.shields.io/discord/1060355106522017924?label=discord" alt="discord">
    </a>
    <a href="https://dogs.helight.dev/">
        <img src="https://img.shields.io/badge/docs-dogs.helight.dev-346ddb.svg" alt="gitbook">
    </a>
    <a href="https://github.com/invertase/melos">
        <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg" alt="melos">
    </a>
</h1>

DOGs, short for Dart Object Graphs, is a universal serialization library making strong use of code
generation to make your code more concise and fluent to write. The core package can be easily extended
to support a wide array of encodings and comes with json support out of the box.

```dart
@serializable
class Person with Dataclass<Person>{

  @LengthRange(max: 128)
  final String name;

  @Minimum(18)
  final int age;

  @SizeRange(max: 16)
  @Regex("((_)?[a-z]+[A-Za-z0-9]*)+")
  final Set<String>? tags;

  Person(this.name, this.age, this.tags);

}
```

* 🐦 **Concise** Write expressive code with effectively zero boilerplate
* 🚀 **Fast** Similar or increased performance compared to alternatives
* 🧩 **Extensible** Modify and customize any part of your serialization
* 📦 **Adaptive** Use one of the various formats or bring your own

## Features
* **Builder extensions** (supporting nullability)
* **Copyable** types (supporting map overrides)
* **OpenApi Schema** Generation (using conduit_open_api)
* **Validation** API (similar to javax.validation)
* **Generator-less extensibility** (using annotations)

## Format Support
- **JSON** (included in dogs_core)
- **YAML** (package dogs_yaml)
- **TOML** (package dogs_toml)
- **CBOR** (package dogs_cbor)

## Silent Code Generation
A neat point about dogs 'darwin like' **non-intrusive** code generation is,
that it has almost **zero boilerplate** and generally **doesn't require
importing or referencing generated source code**, except for use cases which
involve builders or generated extensions. This allows you to keep on working
on your code, without having to wait for the build runner to create your
required files for every new service you create and plan to use.
This also **minimizes conflicts** with other external generators and helps to
prevent unexpected build runner crashes.

## Benchmarks
Benchmarks
A simple comparison between dogs, equatable and built_value has been peformed with following results.
The benchmarks has been run on a single isolate, the code of the benchmark can be found at 'benchmark/'.  
<br>
Dart: 2.19.6  
OS: Ubuntu 22.04.2  
Processor: Intel® Core™ i9-9920X CPU @ 3.50GHz × 24  
Memory: 64GiB DDR4 2133 MT/s  
Results:  
==== Running JsonSerialization Benchmarks (500 items, 1000 iterations)  
Dogs took 921979μs (921.979ms)  
Built took 1180312μs (1180.312ms)  
Native took 835845μs (835.845ms)  
==== Running JsonDeserialization Benchmarks (500 items, 1000 iterations)  
Dogs took 732607μs (732.607ms)  
Built took 968599μs (968.599ms)  
Native took 637777μs (637.777ms)  
==== Running Builder Benchmarks (500 items, 1000 iterations)  
Dogs took 34505μs (34.505ms)  
Built took 47435μs (47.435ms)  
==== Running IndexOf Benchmarks (500 items, 1000 iterations)  
Dogs took 1137425μs (1137.425ms)  
BuiltValue took 1023607μs (1023.607ms)  
Equatable took 4796078μs (4796.078ms)  
Native took 1218228μs (1218.228ms)  
==== Running DirectEquality Benchmarks (1000000 iterations)  
Dogs took 10687μs (10.687ms)  
BuiltValue took 9135μs (9.135ms)  
Equatable took 38516μs (38.516ms)  
Native took 12485μs (12.485ms)  
==== Running MapKey Benchmarks (500 items, 1000 iterations)  
Dogs took 10433μs (10.433ms)  
BuiltValue took 18113μs (18.113ms)  
Equatable took 472721μs (472.721ms)  
Native took 231494μs (231.494ms)  