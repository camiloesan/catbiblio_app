import 'package:flutter/material.dart';

class ControllersData {
  List<DropdownMenuEntry<String>> libraryEntries;
  List<DropdownMenuEntry<String>> itemTypeEntries;
  List<DropdownMenuEntry<String>> filterEntries;

  ControllersData({
    required this.libraryEntries,
    required this.itemTypeEntries,
    required this.filterEntries,
  });
}