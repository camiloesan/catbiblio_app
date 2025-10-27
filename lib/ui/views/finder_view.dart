import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_location.dart';
import 'package:catbiblio_app/models/finder_params.dart';
import 'package:catbiblio_app/services/images.dart';
import 'package:catbiblio_app/services/locations.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';

part '../controllers/finder_controller.dart';

class FinderView extends StatefulWidget {
  final FinderParams params;
  const FinderView({super.key, required this.params});

  @override
  State<FinderView> createState() => _FinderViewState();
}

class _FinderViewState extends FinderController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.finderTitle)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width < 600
                  ? MediaQuery.of(context).size.width
                  : (MediaQuery.of(context).size.width / 3) * 2,
            ),
            child: Column(
              children: [
                Container(
                  color: primaryUVColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Image?>(
                        future: ImageService.fetchImageUrl(
                          widget.params.biblioNumber,
                        ),
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
                          '${widget.params.title}\n\n${AppLocalizations.of(context)!.classification}:\n${widget.params.classification}',
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
                Padding(
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
                      const SizedBox(height: 8.0),
                      Text(
                        AppLocalizations.of(context)!.location,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.params.holdingLibrary,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.level,
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
                                  Icon(
                                    Icons.meeting_room,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.room,
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
                                  Icon(
                                    Icons.library_books,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.collection,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.params.collection,
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
                      InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4,
                        child: Image.asset('assets/images/croquis1.png'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
