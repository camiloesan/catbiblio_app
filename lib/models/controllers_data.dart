import 'package:flutter/material.dart';

class ControllersData {
  TextEditingController filterController;
  TextEditingController libraryController;
  List<DropdownMenuEntry<String>> libraryEntries;
  TextEditingController itemTypeController;

  ControllersData({
    required this.filterController,
    required this.libraryController,
    required this.libraryEntries,
    required this.itemTypeController,
  });
}