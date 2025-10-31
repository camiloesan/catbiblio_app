import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/biblio_item.dart';
import 'package:catbiblio_app/models/biblios_details.dart';
import 'package:catbiblio_app/models/finder_params.dart';
import 'package:catbiblio_app/models/global_provider.dart';
import 'package:catbiblio_app/services/biblios_items.dart';
import 'package:catbiblio_app/services/images.dart';
import 'package:catbiblio_app/ui/views/finder_view.dart';
import 'package:catbiblio_app/ui/views/marc_view.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/biblios_details.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width < screenSizeLimit
                      ? MediaQuery.of(context).size.width
                      : (MediaQuery.of(context).size.width / 3) * 2,
                ),
                child: Column(
                  children: [
                    if (isErrorLoadingDetails)
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.errorLoadingBookDetails,
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Skeletonizer(
                            enabled: isLoadingDetails,
                            child: Container(
                              color: primaryUVColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 24.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen real cuando esté disponible, si está cargando mostramos un mock.
                                  if (isLoadingDetails)
                                    SizedBox(
                                      width: 120,
                                      height: 160,
                                      child: Container(
                                        color: Colors.white24,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    FutureBuilder<Image?>(
                                      future: ImageService.fetchImageUrl(
                                        widget.biblioNumber,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError ||
                                            snapshot.data == null) {
                                          // If there was an error or no image, show a placeholder.
                                          // A small placeholder must be shown after loading. To avoid breaking the layout, we use a reduced placeholder.
                                          return SizedBox(
                                            width: 120,
                                            height: 160,
                                            child: Container(
                                              color: Colors.white24,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 36,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Row(
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                height: 160,
                                                child: snapshot.data!,
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Texto mock mientras carga, título real cuando esté disponible.
                                        Text(
                                          isLoadingDetails
                                              ? mockTitle
                                              : bibliosDetails.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              left: 16.0,
                              right: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Skeletonizer(
                                      enabled: isLoadingDetails,
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.bibliographicDetails,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: BibliographicDetails(
                                        bibliosDetails: bibliosDetails,
                                        languageMap: languageMap,
                                        isLoadingDetails: isLoadingDetails,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Skeletonizer(
                            enabled: isLoadingDetails || isErrorLoadingDetails,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MarcView(
                                          biblioNumber: widget.biblioNumber,
                                        ),
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
                                  label: Text(
                                    AppLocalizations.of(context)!.share,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),

                          if (isErrorLoadingBiblioItems)
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 48,
                                  ),
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
                                  Text(
                                    AppLocalizations.of(context)!.noCopiesFound,
                                  ),
                                ],
                              ),
                            )
                          else
                            Skeletonizer(
                              enabled: isLoadingBiblioItems,
                              child: Text(
                                '${AppLocalizations.of(context)!.copies}: ${biblioItems.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          // buildLibrariesList(isLoadingBiblioItems),
                          ListViewLibrariesWidget(
                            holdingLibraries: holdingLibraries,
                            groupedItems: groupedItems,
                            navigateToFinderView: navigateToFinderView,
                            isLoadingBiblioItems: isLoadingBiblioItems,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListViewLibrariesWidget extends StatelessWidget {
  const ListViewLibrariesWidget({
    super.key,
    required this.holdingLibraries,
    required this.groupedItems,
    required this.navigateToFinderView,
    required this.isLoadingBiblioItems,
  });

  final List<String> holdingLibraries;
  final Map<String, List<BiblioItem>> groupedItems;
  final Function(
    String callNumber,
    String collection,
    String collectionCode,
    String holdingLibrary,
  )
  navigateToFinderView;
  final bool isLoadingBiblioItems;

  @override
  Widget build(BuildContext context) {
    if (isLoadingBiblioItems) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3, // Show 3 placeholder items
        itemBuilder: (context, index) {
          return Skeletonizer.zone(
            child: Card(
              child: ListTile(
                title: Bone.text(words: 4),
                trailing: Bone.icon(),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: holdingLibraries.length,
      itemBuilder: (context, index) {
        final item = holdingLibraries[index];

        return Card(
          color: Colors.grey[100],
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
              dense: true,
              childrenPadding: const EdgeInsets.only(bottom: 8.0),
              title: Text(
                '$item (${groupedItems[item]!.length})',
                style: const TextStyle(fontWeight: FontWeight.w500),
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
                        Provider.of<GlobalProvider>(context)
                                    .globalEnabledLibrariesEntries
                                    .contains(biblioItem.holdingLibraryId) &&
                                biblioItem.homeLibraryId ==
                                    biblioItem.holdingLibraryId &&
                                biblioItem.notForLoanStatus ==
                                    BiblioItem.statusAvailable
                            ? IconButton(
                                onPressed: () => navigateToFinderView(
                                  biblioItem.callNumber,
                                  biblioItem.collection,
                                  biblioItem.collectionCode,
                                  biblioItem.holdingLibrary,
                                ),
                                icon: const Icon(Icons.map),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                    leading: Icon(
                      biblioItem.overAllStatus == BiblioItem.statusBorrowed
                          ? Icons.watch_later
                          : biblioItem.overAllStatus ==
                                BiblioItem.statusNotForLoan
                          ? Icons.lock
                          : Icons.check_circle,
                      color:
                          biblioItem.overAllStatus == BiblioItem.statusBorrowed
                          ? Colors.orange
                          : biblioItem.overAllStatus ==
                                BiblioItem.statusNotForLoan
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
    );
  }
}

class BibliographicDetails extends StatelessWidget {
  const BibliographicDetails({
    super.key,
    required this.bibliosDetails,
    required this.languageMap,
    required this.isLoadingDetails,
  });

  final BibliosDetails bibliosDetails;
  final Map<String, String> languageMap;
  final bool isLoadingDetails;

  @override
  Widget build(BuildContext context) {
    if (isLoadingDetails) {
      bibliosDetails.author = mockAuthor;
      bibliosDetails.editor = mockEditor;
      bibliosDetails.description = mockDescription;
      bibliosDetails.isbn = mockIsbn;
      bibliosDetails.language = mockLanguage;
      bibliosDetails.originalLanguage = mockOriginalLanguage;
      bibliosDetails.subject = mockSubject;
      bibliosDetails.collaborators = mockCollaborators;
      bibliosDetails.summary = mockSummary;
      bibliosDetails.cdd = mockCdd;
      bibliosDetails.loc = mockLoc;
    }

    return Skeletonizer(
      enabled: isLoadingDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bibliosDetails.author.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.author,
              value: bibliosDetails.author,
            ),
          if (bibliosDetails.editor.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.editor,
              value: bibliosDetails.editor,
            ),
          if (bibliosDetails.edition.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.edition,
              value: bibliosDetails.edition,
            ),
          if (bibliosDetails.description.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.description,
              value: bibliosDetails.description,
            ),
          if (bibliosDetails.isbn.isNotEmpty)
            SingleBiblioDetailWrap(label: 'ISBN', value: bibliosDetails.isbn),
          if (bibliosDetails.language.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.language,
              value:
                  languageMap[bibliosDetails.language] ??
                  bibliosDetails.language,
            ),
          if (bibliosDetails.originalLanguage.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.originalLanguage,
              value:
                  languageMap[bibliosDetails.originalLanguage] ??
                  bibliosDetails.originalLanguage,
            ),
          if (bibliosDetails.subject.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.subject,
              value: bibliosDetails.subject,
            ),
          if (bibliosDetails.collaborators.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.collaborators,
              value: bibliosDetails.collaborators,
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
                  trimExpandedText:
                      ' ${AppLocalizations.of(context)!.showLess}',
                  // style: const TextStyle(fontSize: 14),
                ),
                // Text(bibliosDetails.summary),
              ],
            ),
          if (bibliosDetails.cdd.isNotEmpty)
            SingleBiblioDetailWrap(label: 'CDD', value: bibliosDetails.cdd),
          if (bibliosDetails.loc.isNotEmpty)
            SingleBiblioDetailWrap(label: 'LOC', value: bibliosDetails.loc),
          if (bibliosDetails.otherClassification.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.otherClassification,
              value: bibliosDetails.otherClassification,
            ),
          if (bibliosDetails.lawClassification.isNotEmpty)
            SingleBiblioDetailWrap(
              label: AppLocalizations.of(context)!.lawClassification,
              value: bibliosDetails.lawClassification,
            ),
        ],
      ),
    );
  }

  final mockAuthor = 'John Doe';
  final mockEditor = 'Jane Editor';
  final mockDescription = 'Brief description of the work.';
  final mockIsbn = 'ISBN 000-0-00-000000-0';
  final mockLanguage = 'eng';
  final mockOriginalLanguage = 'fre';
  final mockSubject = 'Sample subject, keywords';
  final mockCollaborators = 'A. Collaborator; B. Collaborator';
  final mockSummary =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus non felis eu justo '
      'viverra pulvinar. Curabitur ac orci a lorem posuere tincidunt. Integer vitae dui nec ';
  final mockCdd = '000';
  final mockLoc = 'QA76.XX XX XXX';
}

class SingleBiblioDetailWrap extends StatelessWidget {
  const SingleBiblioDetailWrap({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
