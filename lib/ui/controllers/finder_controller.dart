part of '../views/finder_view.dart';

abstract class FinderController extends State<FinderView> {
  late BookLocation bookLocation = BookLocation(level: '', room: '');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    BookLocation? location;

    try {
      location = await LocationsService.getBookLocation(
        widget.classification,
        widget.collectionCode,
      );
    } catch (error) {
      debugPrint('Error loading details: $error');
    }

    setState(() {
      bookLocation = location ?? bookLocation;
    });
  }
}