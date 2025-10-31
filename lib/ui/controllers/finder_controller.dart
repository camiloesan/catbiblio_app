part of '../views/finder_view.dart';

abstract class FinderController extends State<FinderView> {
  late BookLocation bookLocation = BookLocation(level: '', room: '');
  final int screenSizeLimit = 800;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    BookLocation? location;

    try {
      location = await LocationsService.getBookLocation(
        widget.params.classification,
        widget.params.collectionCode,
      );
    } catch (error) {
      debugPrint('Error loading details: $error');
    }

    setState(() {
      bookLocation = location ?? bookLocation;
    });
  }
}