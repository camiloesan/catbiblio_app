part of '../views/book_view.dart';

abstract class BookController extends State<BookView> {
  late BibliosDetails bibliosDetails = BibliosDetails(title: '', author: '');
  late List<BiblioItem> biblioItems = [];
  bool isLoadingDetails = true;
  bool isErrorLoadingDetails = false;
  bool isLoadingBiblioItems = true;
  bool isErrorLoadingBiblioItems = false;
  final Map<String, List<BiblioItem>> groupedItems = {};
  final List<String> holdingLibraries = [];
  final int screenSizeLimit = 800;

  final mockTitle =
      'Título de ejemplo para mostrar en la interfaz de usuario mientras se cargan los datos reales del libro.';

  Map<String, String> get languageMap => {
    'eng': AppLocalizations.of(context)!.english,
    'spa': AppLocalizations.of(context)!.spanish,
    'fre': AppLocalizations.of(context)!.french,
    'ger': AppLocalizations.of(context)!.german,
    'jpn': AppLocalizations.of(context)!.japanese,
    'ita': AppLocalizations.of(context)!.italian,
    'por': AppLocalizations.of(context)!.portuguese,
    'rus': AppLocalizations.of(context)!.russian,
    'chi': AppLocalizations.of(context)!.chinese,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final biblioNumber = int.parse(widget.biblioNumber);

    BibliosDetails? details;
    List<BiblioItem> items = [];

    bool detailsError = false;
    bool itemsError = false;

    try {
      details = await BibliosDetailsService.getBibliosDetails(biblioNumber);
    } catch (error) {
      debugPrint('Error loading details: $error');
      detailsError = true;
    }

    try {
      items = await BibliosItemsService.getBiblioItems(biblioNumber);
    } catch (error) {
      debugPrint('Error loading items: $error');
      itemsError = true;
    }

    if (!mounted) return;

    final grouped = <String, List<BiblioItem>>{};
    for (var book in items) {
      (grouped[book.holdingLibrary] ??= []).add(book);
    }

    setState(() {
      bibliosDetails = details ?? bibliosDetails;
      biblioItems = items;
      groupedItems.clear();
      groupedItems.addAll(grouped);
      holdingLibraries
        ..clear()
        ..addAll(grouped.keys);

      isLoadingDetails = false;
      isLoadingBiblioItems = false;
      isErrorLoadingDetails = detailsError;
      isErrorLoadingBiblioItems = itemsError;
    });
  }

  void showShareDialog(
    BuildContext context,
    String title,
    String biblioNumber,
  ) {
    final String message =
        'Catálogo Bibliotecario de la Universidad Veracruzana:\n"$title":\nhttps://catbiblio.uv.mx/cgi-bin/koha/opac-detail.pl?biblionumber=$biblioNumber';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.shareVia),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Important to keep the dialog compact
            children: <Widget>[
              // WhatsApp Share Tile
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('WhatsApp'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _shareOnWhatsApp(context, message);
                },
              ),
              // Email Share Tile
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(AppLocalizations.of(context)!.email),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  _shareViaEmail(context, message);
                },
              ),
            ],
          ),
          actions: <Widget>[
            // A 'Cancel' button to close the dialog
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareOnWhatsApp(BuildContext context, String message) async {
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotLaunchWhatsApp),
        ),
      );
    }
  }

  void navigateToFinderView(
    String callNumber,
    String collection,
    String collectionCode,
    String holdingLibrary,
  ) {
    FinderParams params = FinderParams(
      biblioNumber: widget.biblioNumber,
      title: bibliosDetails.title,
      classification: callNumber,
      collection: collection,
      collectionCode: collectionCode,
      holdingLibrary: holdingLibrary,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinderView(params: params)),
    );
  }

  Future<void> _shareViaEmail(BuildContext context, String message) async {
    final Uri emailUri = Uri.parse(
      'mailto:?subject=&body=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotFindEmailClient),
        ),
      );
    }
  }
}
