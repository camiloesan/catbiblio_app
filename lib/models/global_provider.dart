import 'package:catbiblio_app/models/config.dart';
import 'package:flutter/material.dart';

class GlobalProvider with ChangeNotifier {
  List<DropdownMenuEntry<String>> _globalLibraryEntries = [];
  List<DropdownMenuEntry<String>> _globalItemTypeEntries = [];
  Set<String> _globalEnabledLibrariesFinder = {};

  List<DropdownMenuEntry<String>> get globalLibraryEntries =>
      _globalLibraryEntries;

  List<DropdownMenuEntry<String>> get globalItemTypeEntries =>
      _globalItemTypeEntries;

  Set<String> get globalEnabledLibrariesEntries =>
      _globalEnabledLibrariesFinder;

  void setGlobalLibraryEntries(List<DropdownMenuEntry<String>> entries) {
    _globalLibraryEntries = entries;
    notifyListeners();
  }

  void setGlobalItemTypeEntries(List<DropdownMenuEntry<String>> entries) {
    _globalItemTypeEntries = entries;
    notifyListeners();
  }

  void setGlobalEnabledLibrariesEntries(
      Set<String> entries) {
    _globalEnabledLibrariesFinder = entries;
    notifyListeners();
  }
}