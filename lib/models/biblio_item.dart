//import 'package:catbiblio_app/models/item_location.dart';

class BiblioItem {
  String itemType; // Currently only displaying the id: item_types endpoint
  String holdingLibrary; // Currently only displaying the id: libraries endpoint
  String collection; // Currently only displaying the id: CCODE authorised value
  String callNumber;
  String callNumberSort;
  String copyNumber;
  int notForLoanStatus;
  String? checkedOutDate;
  bool borrowedStatus; // Not in json, calculated based on checkedOutDate
  /*
  ItemLocation
  location; // Used for geographical location - not in json: to be calculated later
  */

  BiblioItem({
    required this.itemType,
    required this.holdingLibrary,
    required this.collection,
    required this.callNumber,
    required this.callNumberSort,
    required this.copyNumber,
    required this.notForLoanStatus,
    this.checkedOutDate,
    this.borrowedStatus = false,
    //ItemLocation? location,
  });
  /*: location =
           location ??
           ItemLocation(floor: '', room: '', shelf: '', shelfSide: '');*/

  factory BiblioItem.fromJson(Map<String, dynamic> json) {
    return BiblioItem(
      itemType: json['item_type_id'],
      holdingLibrary: json['holding_library_id'],
      collection: json['collection_code'],
      callNumber: json['callnumber'],
      callNumberSort: json['call_number_sort'],
      copyNumber: json['copy_number'],
      notForLoanStatus: json['not_for_loan_status'],
      checkedOutDate: json['checked_out_date'] as String?,
      borrowedStatus: json['checked_out_date'] != null,
    );
  }

  @override
  String toString() {
    return 'BiblioItem(itemType: $itemType, holdingLibrary: $holdingLibrary, collection: $collection, callNumber: $callNumber, callNumberSort: $callNumberSort, copyNumber: $copyNumber, notForLoanStatus: $notForLoanStatus, checkedOutDate: $checkedOutDate, borrowedStatus: $borrowedStatus)';
  }
}
