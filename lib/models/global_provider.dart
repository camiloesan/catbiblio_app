import 'package:flutter/material.dart';

class GlobalProvider with ChangeNotifier {
  List<DropdownMenuEntry<String>> _globalLibraryEntries = [];
  List<DropdownMenuEntry<String>> _globalItemTypeEntries = [];

  List<DropdownMenuEntry<String>> get globalLibraryEntries =>
      _globalLibraryEntries;

  List<DropdownMenuEntry<String>> get globalItemTypeEntries =>
      _globalItemTypeEntries;

  void setGlobalLibraryEntries(List<DropdownMenuEntry<String>> entries) {
    _globalLibraryEntries = entries;
    notifyListeners();
  }

  void setGlobalItemTypeEntries(List<DropdownMenuEntry<String>> entries) {
    _globalItemTypeEntries = entries;
    notifyListeners();
  }
}