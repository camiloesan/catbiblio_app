class Config {
  final List<BookSelection> bookSelections;
  final List<LibraryServices> librariesServices;
  final List<String> bookFinderLibraries;
  final bool selectionsSectionState;

  Config({
    required this.bookSelections,
    required this.librariesServices,
    required this.bookFinderLibraries,
    required this.selectionsSectionState,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      bookSelections: (json['book_selections'] as List<dynamic>? ?? [])
          .map((e) => BookSelection.fromJson(e))
          .toList(),
      librariesServices: (json['libraries_services'] as List<dynamic>? ?? [])
          .map((e) => LibraryServices.fromJson(e))
          .toList(),
      bookFinderLibraries:
          (json['book_finder_libraries'] as List<dynamic>? ?? [])
              .map((e) => e['library_code'] as String? ?? '')
              .toList(),
      selectionsSectionState:
          json['is_selections_section_enabled'] as bool? ?? false,
    );
  }
}

class BookSelection {
  final String bookName;
  final String biblionumber;

  BookSelection({required this.bookName, required this.biblionumber});

  factory BookSelection.fromJson(Map<String, dynamic> json) {
    return BookSelection(
      bookName: json['book_name'] ?? '',
      biblionumber: json['biblionumber'] ?? '',
    );
  }
}

class LibraryCode {
  final String libraryCode;

  LibraryCode({required this.libraryCode});

  factory LibraryCode.fromJson(Map<String, dynamic> json) {
    return LibraryCode(libraryCode: json['library_code'] ?? '');
  }
}

class LibraryServices {
  final String libraryCode;
  final String libraryName;
  final List<Service> services;

  LibraryServices({required this.libraryCode, required this.libraryName, required this.services});

  factory LibraryServices.fromJson(Map<String, dynamic> json) {
    return LibraryServices(
      libraryCode: json['library_code'] ?? '',
      libraryName: json['library_name'] ?? '',
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => Service.fromJson(e))
          .toList(),
    );
  }
}

class Service {
  final String name;
  final String imageUrl;

  Service({required this.name, required this.imageUrl});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(name: json['name'] ?? '', imageUrl: json['image_url'] ?? '');
  }
}
