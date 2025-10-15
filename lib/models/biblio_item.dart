//import 'package:catbiblio_app/models/item_location.dart';

class BiblioItem {
  static const int statusAvailable = 0;
  static const int statusBorrowed = 1;
  static const int statusNotForLoan = 2;

  String itemTypeId;
  String itemType;
  String holdingLibraryId;
  String holdingLibrary;
  String homeLibraryId;
  String collectionCode;
  String collection;
  String callNumber;
  String callNumberSort;
  String copyNumber;
  int notForLoanStatus;
  String? checkedOutDate;
  bool borrowedStatus; // Not in json, calculated based on checkedOutDate
  int
  overAllStatus; // Not in json, to be calculated later 0 = available, 1 = borrowed, 2 = not for loan
  /*
  ItemLocation
  location; // Used for geographical location - not in json: to be calculated later
  */

  BiblioItem({
    required this.itemTypeId,
    required this.itemType,
    required this.holdingLibraryId,
    required this.holdingLibrary,
    required this.homeLibraryId,
    required this.collectionCode,
    required this.collection,
    required this.callNumber,
    required this.callNumberSort,
    required this.copyNumber,
    required this.notForLoanStatus,
    this.checkedOutDate,
    this.borrowedStatus = false,
    //ItemLocation? location,
  }) : overAllStatus = notForLoanStatus != statusAvailable
           ? statusNotForLoan
           : (checkedOutDate != null ? statusBorrowed : statusAvailable);
  /*: location =
           location ??
           ItemLocation(floor: '', room: '', shelf: '', shelfSide: '');*/

  factory BiblioItem.fromJson(Map<String, dynamic> json) {
    final checkedOutDate = json['checked_out_date'] as String?;
    final notForLoanStatus = json['not_for_loan_status'];
    return BiblioItem(
      itemTypeId: json['item_type_id'],
      itemType: json['item_type'],
      holdingLibraryId: json['holding_library_id'],
      holdingLibrary: json['holding_library'],
      homeLibraryId: json['home_library_id'],
      collectionCode: json['collection_code'],
      collection: json['collection'],
      callNumber: json['callnumber'],
      callNumberSort: json['call_number_sort'],
      copyNumber: json['copy_number'],
      notForLoanStatus: notForLoanStatus,
      checkedOutDate: checkedOutDate,
      borrowedStatus: checkedOutDate != null,
    );
  }

  @override
  String toString() {
    return 'BiblioItem(itemTypeId: $itemTypeId, itemType: $itemType, holdingLibraryId: $holdingLibraryId, holdingLibrary: $holdingLibrary, collectionCode: $collectionCode, collection: $collection, callNumber: $callNumber, callNumberSort: $callNumberSort, copyNumber: $copyNumber, notForLoanStatus: $notForLoanStatus, checkedOutDate: $checkedOutDate, borrowedStatus: $borrowedStatus, overAllStatus: $overAllStatus)';
  }
}
