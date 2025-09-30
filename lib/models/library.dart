class Library {
  String libraryId;
  String name;
  String area;
  String address;
  String postalCode;
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
    this.postalCode = '',
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
      area: json['address3'] as String? ?? '',
      address: json['address1'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
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
      'postal_code': postalCode,
      'city': city,
      'state': state,
      'country': country,
      'email': email,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'Library(libraryId: $libraryId, name: $name, area: $area, address: $address, postalCode: $postalCode, city: $city, state: $state, country: $country, email: $email, url: $url)';
  }
}
