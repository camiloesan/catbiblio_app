class ItemType {
  final String id;
  final String description;

  ItemType({required this.id, required this.description});

  factory ItemType.fromJson(Map<String, dynamic> json) {
    return ItemType(
      id: json['item_type_id'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'ItemType{id: $id, description: $description}';
  }
}
