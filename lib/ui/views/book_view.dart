import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/biblio_item.dart';
import 'package:catbiblio_app/models/biblios_details.dart';
import 'package:catbiblio_app/services/rest/biblios_items.dart';
import 'package:catbiblio_app/services/rest/images.dart';
import 'package:catbiblio_app/ui/views/marc_view.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/rest/biblios_details.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.detailsTitle)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: [
                  if (isLoadingDetails)
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    )
                  else if (isErrorLoadingDetails)
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8.0),
                          Text('Error loading book details'),
                        ],
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: primaryUVColor,
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Image?>(
                              future: ImageService.fetchImageUrl(
                                widget.biblioNumber,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return const SizedBox.shrink();
                                } else {
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: snapshot.data!,
                                      ),
                                      const SizedBox(width: 16.0),
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
                    AppLocalizations.of(context)!.bibliographicDetails,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: BibliographicDetails(
                      bibliosDetails: bibliosDetails,
                      languageMap: languageMap,
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MarcView(biblioNumber: widget.biblioNumber),
                            ),
                          );
                        },
                        icon: const Icon(Icons.library_books),
                        label: const Text('MARC'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          showShareDialog(
                            context,
                            bibliosDetails.title,
                            widget.biblioNumber,
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: Text(AppLocalizations.of(context)!.share),
                      ),
                    ],
                  ),
                  const Divider(),

                  if (isErrorLoadingBiblioItems)
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8.0),
                          Text('Error loading item copies'),
                        ],
                      ),
                    )
                  else if (biblioItems.isEmpty && !isLoadingDetails)
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info,
                            color: primaryUVColor,
                            size: 48,
                          ),
                          const SizedBox(height: 8.0),
                          Text(AppLocalizations.of(context)!.noCopiesFound),
                        ],
                      ),
                    )
                  else
                    Text(
                      '${AppLocalizations.of(context)!.copies}: ${biblioItems.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: holdingLibraries.length,
                    itemBuilder: (context, index) {
                      final item = holdingLibraries[index];

                      return Card(
                        color: Colors.grey[100],
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            dense: true,
                            childrenPadding: const EdgeInsets.only(bottom: 8.0),
                            title: Text(
                              '$item (${groupedItems[item]!.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: groupedItems[item]!.map((biblioItem) {
                              return Card(
                                child: ExpansionTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${AppLocalizations.of(context)!.classification}:\n${biblioItem.callNumber}',
                                        ),
                                      ),
                                      biblioItem.holdingLibraryId == 'USBI-X' &&
                                              biblioItem.notForLoanStatus ==
                                                  BiblioItem.STATUS_AVAILABLE
                                          ? IconButton(
                                              onPressed: () {},
                                              icon: const Icon(Icons.map),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                  leading: Icon(
                                    biblioItem.overAllStatus ==
                                            BiblioItem.STATUS_BORROWED
                                        ? Icons.remove_circle
                                        : biblioItem.overAllStatus ==
                                              BiblioItem.STATUS_NOT_FOR_LOAN
                                        ? Icons.remove_circle
                                        : Icons.check_circle,
                                    color:
                                        biblioItem.overAllStatus ==
                                            BiblioItem.STATUS_BORROWED
                                        ? Colors.orange
                                        : biblioItem.overAllStatus ==
                                              BiblioItem.STATUS_NOT_FOR_LOAN
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  childrenPadding: const EdgeInsets.only(
                                    left: 16.0,
                                    right: 16.0,
                                    bottom: 8.0,
                                  ),
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.itemType}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(biblioItem.itemType),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.holdingLibrary}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(biblioItem.holdingLibrary),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.collection}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(biblioItem.collection),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.classification}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(biblioItem.callNumber),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        children: [
                                          Text(
                                            '${AppLocalizations.of(context)!.copyNumber}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(biblioItem.copyNumber),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BibliographicDetails extends StatelessWidget {
  const BibliographicDetails({
    super.key,
    required this.bibliosDetails,
    required this.languageMap,
  });

  final BibliosDetails bibliosDetails;
  final Map<String, String> languageMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bibliosDetails.author.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.author}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.author),
            ],
          ),
        if (bibliosDetails.editor.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.editor}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.editor),
            ],
          ),
        if (bibliosDetails.edition.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.edition}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.edition),
            ],
          ),
        if (bibliosDetails.description.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.description}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.description),
            ],
          ),
        if (bibliosDetails.isbn.isNotEmpty)
          Wrap(
            children: [
              Text(
                'ISBN: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.isbn),
            ],
          ),
        if (bibliosDetails.language.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.language}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                languageMap[bibliosDetails.language] ?? bibliosDetails.language,
              ),
            ],
          ),
        if (bibliosDetails.originalLanguage.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.originalLanguage}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                languageMap[bibliosDetails.originalLanguage] ??
                    bibliosDetails.originalLanguage,
              ),
            ],
          ),
        if (bibliosDetails.subject.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.subject}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.subject),
            ],
          ),
        if (bibliosDetails.collaborators.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.collaborators}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.collaborators),
            ],
          ),
        if (bibliosDetails.summary.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.summary,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  // fontSize: 16,
                ),
              ),
              ReadMoreText(
                bibliosDetails.summary,
                trimLines: 4,
                colorClickableText: Colors.blue,
                trimMode: TrimMode.Line,
                trimCollapsedText:
                    '... ${AppLocalizations.of(context)!.readMore}',
                trimExpandedText: ' ${AppLocalizations.of(context)!.showLess}',
                // style: const TextStyle(fontSize: 14),
              ),
              // Text(bibliosDetails.summary),
            ],
          ),
        if (bibliosDetails.cdd.isNotEmpty)
          Wrap(
            children: [
              Text(
                'CDD: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.cdd),
            ],
          ),
        if (bibliosDetails.loc.isNotEmpty)
          Wrap(
            children: [
              Text(
                'LOC: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.loc),
            ],
          ),
        if (bibliosDetails.otherClassification.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.otherClassification}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.otherClassification),
            ],
          ),
        if (bibliosDetails.lawClassification.isNotEmpty)
          Wrap(
            children: [
              Text(
                '${AppLocalizations.of(context)?.lawClassification}: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(bibliosDetails.lawClassification),
            ],
          ),
      ],
    );
  }
}
