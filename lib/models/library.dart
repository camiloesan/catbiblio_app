class Library {
  String libraryId;
  String name;
  String area;
  String address;
  String zipCode;
  String city;
  String state;
  String country;
  String email;
  String url;

  Library({
    required this.libraryId,
    required this.name,
    this.area = '',
    this.address = '',
    this.zipCode = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.email = '',
    this.url = '',
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      libraryId: json['library_id'] as String,
      name: json['name'] as String,
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      email: json['email'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'library_id': libraryId,
      'name': name,
      'area': area,
      'address': address,
      'zip_code': zipCode,
      'city': city,
      'state': state,
      'country': country,
      'email': email,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'Library(libraryId: $libraryId, name: $name, area: $area, address: $address, zipCode: $zipCode, city: $city, state: $state, country: $country, email: $email, url: $url)';
  }
}
