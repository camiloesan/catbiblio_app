import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

part '../controllers/book_controller.dart';

class BookView extends StatefulWidget {
  final String biblioNumber;
  const BookView({super.key, required this.biblioNumber});

  @override
  State<BookView> createState() => _BookViewState();
}
  
class _BookViewState extends BookController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.detailsTitle),
      ),
      body: Center(
        child: Text('Book ID: ${widget.biblioNumber}'),
      ),
    );
  }
}