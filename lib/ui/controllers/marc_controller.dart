part of '../views/marc_view.dart';

abstract class MarcController extends State<MarcView> {
  String? marcData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    loadMarcData();
  }

  Future<void> loadMarcData() async {
    final biblioNumber = int.parse(widget.biblioNumber);
    try {
      marcData = await BibliosDetailsService.getBibliosMarcPlainText(
        biblioNumber,
      );
    } catch (e) {
      debugPrint('Error loading MARC data: $e');
      isError = true;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
