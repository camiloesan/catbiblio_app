import 'package:flutter/material.dart';

class ControllersData {
  TextEditingController filterController;
  TextEditingController libraryController;
  List<DropdownMenuEntry<String>> libraryEntries;
  List<DropdownMenuEntry<String>> itemTypeEntries;
  TextEditingController itemTypeController;

  ControllersData({
    required this.filterController,
    required this.libraryController,
    required this.libraryEntries,
    required this.itemTypeController,
    required this.itemTypeEntries,
  });
}