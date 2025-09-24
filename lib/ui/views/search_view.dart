import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/svc/search.dart';
import 'package:catbiblio_app/services/svc/images.dart';

part '../controllers/search_controller.dart';

const Color primaryColor = Color(0xFF003466);

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends SearchController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.searchTitle)),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                controller: _filterController,
                label: Text(AppLocalizations.of(context)!.search),
                leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
                dropdownMenuEntries: _filterEntries,
                onSelected: (value) => queryParams.searchBy = value!,
                enableFilter: false,
                requestFocusOnTap: false,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              DropdownMenu(
                controller: _libraryController,
                label: Text(AppLocalizations.of(context)!.library),
                leadingIcon: const Icon(
                  Icons.location_city,
                  color: primaryColor,
                ),
                dropdownMenuEntries: _libraryEntries,
                onSelected: (value) => queryParams.library = value!,
                enableFilter: false,
                requestFocusOnTap: false,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onSubmitted: (value) => onSubmitAction(value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  labelText: AppLocalizations.of(context)!.search,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 2.0,
                    children: [
                      for (
                        int i = setLowerLimit;
                        i <= setUpperLimit && i <= totalPages && totalPages > 1;
                        i++
                      )
                        OutlinedButton(
                          onPressed: () => paginationBehavior(i),
                          style: i == currentPage
                              ? OutlinedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(36, 36),
                                  padding: EdgeInsets.zero,
                                )
                              : OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  minimumSize: Size(36, 36),
                                  padding: EdgeInsets.zero,
                                ),
                          child: i == setUpperLimit
                              ? const Icon(Icons.arrow_forward)
                              : i == setLowerLimit && i > 8
                              ? const Icon(Icons.arrow_back)
                              : Text('$i'),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              if (isInitialRequestLoading)
                Center(child: LinearProgressIndicator())
              else if (books.isEmpty)
                Text(
                  AppLocalizations.of(context)!.noResults,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              else
                Text(
                  textAlign: TextAlign.center,
                  '$totalRecords ${AppLocalizations.of(context)!.totalResults}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              Divider(color: Colors.grey),
              if (isPageLoading)
                Center(child: LinearProgressIndicator())
              else
                ...books.map((book) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookView(biblioNumber: book.biblioNumber),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Image?>(
                                future: ImageService.fetchImageUrl(
                                  book.biblioNumber,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError ||
                                      snapshot.data == null) {
                                    // Error or not PNG
                                    return const SizedBox.shrink();
                                  } else {
                                    // Show the actual image
                                    return SizedBox(child: snapshot.data!);
                                  }
                                },
                              ),

                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    book.author.isEmpty
                                        ? const SizedBox.shrink()
                                        : Text(
                                            '${AppLocalizations.of(context)!.byAuthor}: ${book.author}',
                                          ),
                                    book.publishingDetails.isEmpty
                                        ? const SizedBox.shrink()
                                        : Text(
                                            '${AppLocalizations.of(context)!.publishingDetails}: ${book.publishingDetails}',
                                          ),
                                    Text(
                                      '${AppLocalizations.of(context)!.availability}: 1 biblioteca',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),

                      Divider(color: Colors.grey),
                    ],
                  );
                }),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      spacing: 2.0,
                      children: [
                        for (
                          int i = setLowerLimit;
                          books.length > 5 &&
                              i <= setUpperLimit &&
                              i <= totalPages &&
                              totalPages > 1;
                          i++
                        )
                          OutlinedButton(
                            onPressed: () {
                              paginationBehavior(i);
                              _scrollController.position.maxScrollExtent;
                            },
                            style: i == currentPage
                                ? OutlinedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(36, 36),
                                    padding: EdgeInsets.zero,
                                  )
                                : OutlinedButton.styleFrom(
                                    foregroundColor: primaryColor,
                                    minimumSize: Size(36, 36),
                                    padding: EdgeInsets.zero,
                                  ),
                            child: i == setUpperLimit
                                ? const Icon(Icons.arrow_forward)
                                : i == setLowerLimit && i > 8
                                ? const Icon(Icons.arrow_back)
                                : Text('$i'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
