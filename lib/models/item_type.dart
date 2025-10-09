class ItemType {
  final String itemTypeId;
  final String description;

  ItemType({required this.itemTypeId, required this.description});

  factory ItemType.fromJson(Map<String, dynamic> json) {
    return ItemType(
      itemTypeId: json['item_type_id'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'ItemType{itemTypeId: $itemTypeId, description: $description}';
  }
}
