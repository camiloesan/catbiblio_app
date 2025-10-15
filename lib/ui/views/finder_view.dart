import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_location.dart';
import 'package:catbiblio_app/services/images.dart';
import 'package:catbiblio_app/services/locations.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';

part '../controllers/finder_controller.dart';

class FinderView extends StatefulWidget {
  final String biblioNumber;
  final String title;
  final String classification;
  final String collection;
  final String collectionCode;
  const FinderView({
    super.key,
    required this.biblioNumber,
    required this.title,
    required this.classification,
    required this.collection,
    required this.collectionCode,
  });

  @override
  State<FinderView> createState() => _FinderViewState();
}

class _FinderViewState extends FinderController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.finderTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 0.0,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  color: primaryUVColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
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
                                const SizedBox(width: 16.0),
                              ],
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          '${widget.title}\n\n${AppLocalizations.of(context)!.classification}:\n${widget.classification}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),
              Text(
                AppLocalizations.of(context)!.location,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Nivel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bookLocation.level,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Sala',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bookLocation.room,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Colección',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.collection,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.asset('assets/images/croquis1.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
