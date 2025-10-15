class BookLocation {
  String level;
  String room;

  BookLocation({
    required this.level,
    required this.room,
  });

  factory BookLocation.fromJson(Map<String, dynamic> json) {
    return BookLocation(
      level: json['nivel'] as String? ?? '',
      room: json['sala'] as String? ?? '',
    );
  }
}
