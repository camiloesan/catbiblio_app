class Library {
  String libraryId;
  String name;

  Library({required this.libraryId, required this.name});

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      libraryId: json['library_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'library_id': libraryId, 'name': name};
  }

  @override
  String toString() {
    return 'Library(libraryId: $libraryId, name: $name)';
  }
}
