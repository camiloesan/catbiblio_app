class Config {
  final List<LibraryServices> librariesServices;

  Config({
    required this.librariesServices,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      librariesServices: (json['libraries_services'] as List<dynamic>? ?? [])
          .map((e) => LibraryServices.fromJson(e))
          .toList(),
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
