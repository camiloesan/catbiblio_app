class ItemLocation {
  String floor; // -1, 0, 1, 2, 3
  String room; // Sala 1, Sala 2, etc.
  String shelf;
  String shelfSide; // A or B

  ItemLocation({
    required this.floor,
    required this.room,
    required this.shelf,
    required this.shelfSide,
  });
}
