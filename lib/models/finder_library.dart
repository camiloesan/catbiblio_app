class FinderLibrary {
  final String libraryCode;

  FinderLibrary({required this.libraryCode});

  factory FinderLibrary.fromJson(Map<String, dynamic> json) {
    return FinderLibrary(
      libraryCode: json['library_code'] as String,
    );
  }

  @override
  String toString() {
    return 'FinderLibrary(libraryCode: $libraryCode)';
  }
}
