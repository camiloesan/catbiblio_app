import 'package:flutter/material.dart';

class ControllersData {
  TextEditingController filterController;
  TextEditingController libraryController;
  List<DropdownMenuEntry<String>> libraryEntries;

  ControllersData({
    required this.filterController,
    required this.libraryController,
    required this.libraryEntries,
  });
}