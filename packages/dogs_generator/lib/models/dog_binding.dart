class DogBinding {
  String name;
  String package;
  List<String> converterNames;
  String converterPackage;

  String get key => "$package#$name";

//<editor-fold desc="Data Methods">

  DogBinding({
    required this.name,
    required this.package,
    required this.converterNames,
    required this.converterPackage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DogBinding &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          package == other.package &&
          converterNames == other.converterNames &&
          converterPackage == other.converterPackage);

  @override
  int get hashCode =>
      name.hashCode ^ package.hashCode ^ converterNames.hashCode ^ converterPackage.hashCode;

  @override
  String toString() {
    return 'DogBinding{ name: $name, package: $package, converterNames: $converterNames, converterPackage: $converterPackage,}';
  }

  DogBinding copyWith({
    String? name,
    String? package,
    List<String>? converterNames,
    String? converterPackage,
  }) {
    return DogBinding(
      name: name ?? this.name,
      package: package ?? this.package,
      converterNames: converterNames ?? this.converterNames,
      converterPackage: converterPackage ?? this.converterPackage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'package': package,
      'converterNames': converterNames,
      'converterPackage': converterPackage,
    };
  }

  factory DogBinding.fromMap(Map<String, dynamic> map) {
    return DogBinding(
      name: map['name'] as String,
      package: map['package'] as String,
      converterNames: (map['converterNames'] as List).cast<String>(),
      converterPackage: map['converterPackage'] as String,
    );
  }

//</editor-fold>
}
