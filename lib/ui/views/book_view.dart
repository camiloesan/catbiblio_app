import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/biblios_details.dart';
import 'package:catbiblio_app/services/svc/images.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/rest/biblios_details.dart';

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
      body: FutureBuilder(
        future: _bibliosDetailsFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Error loading book details'));
          } else if (!asyncSnapshot.hasData) {
            return Center(child: Text('No book details found'));
          } else {
            bibliosDetails = asyncSnapshot.data!;
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 8.0,
                right: 8.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Image?>(
                        future: ImageService.fetchImageUrl(widget.biblioNumber),
                        builder: (context, snapshot) {
                          if (snapshot.hasError || snapshot.data == null) {
                            return const SizedBox.shrink();
                          } else {
                            return Row(
                              children: [
                                SizedBox(width: 120, child: snapshot.data!),
                                const SizedBox(width: 8.0),
                              ],
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          bibliosDetails.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${AppLocalizations.of(context)?.byAuthor}: ${bibliosDetails.author}',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
