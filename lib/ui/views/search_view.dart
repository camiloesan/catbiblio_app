import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/controllers_data.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/search.dart';
import 'package:catbiblio_app/services/images.dart';

part '../controllers/search_controller.dart';

const Color primaryUVColor = Color(0xFF003466);

class SearchView extends StatefulWidget {
  final ControllersData controllersData;
  final QueryParams queryParams;

  const SearchView({
    super.key,
    required this.controllersData,
    required this.queryParams,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends SearchController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.search)),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Top controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width < 600
                          ? MediaQuery.of(context).size.width
                          : (MediaQuery.of(context).size.width / 3) * 2,
                    ),
                    child: Column(
                      children: [
                        DropdownItemType(
                          itemTypeController: _itemTypeController,
                          itemTypeEntries:
                              widget.controllersData.itemTypeEntries,
                          queryParams: widget.queryParams,
                        ),
                        const SizedBox(height: 12),
                        DropdownFilter(
                          filterController: _filterController,
                          filterEntries: _filterEntries,
                          widget: widget,
                        ),
                        const SizedBox(height: 12),
                        DropdownLibraries(
                          libraryController: _libraryController,
                          widget: widget,
                        ),
                        const SizedBox(height: 12),
                        textFieldSearch(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  buildPaginationButtonRow(),
                  const SizedBox(height: 8),
                  if (isInitialRequestLoading)
                    const Center(child: LinearProgressIndicator()),
                  if (isError)
                    Text(
                      AppLocalizations.of(context)!.errorOccurred,
                      textAlign: TextAlign.center,
                    ),
                  if (books.isEmpty &&
                      !isInitialRequestLoading &&
                      !isError &&
                      !isPageLoading)
                    Text(
                      AppLocalizations.of(context)!.noResults,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  else if (!isInitialRequestLoading &&
                      !isError &&
                      !isPageLoading)
                    Text(
                      '$totalRecords ${AppLocalizations.of(context)!.totalResults}',
                      textAlign: TextAlign.center,
                    ),
                  const Divider(color: Colors.grey),
                  if (isPageLoading)
                    const Center(child: LinearProgressIndicator()),
                ],
              ),
            ),
          ),

          // Book list (only rendered if not page loading)
          if (!isPageLoading) BookList(books: books),

          // Bottom pagination
          if (!isPageLoading && books.length > 5)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: buildPaginationButtonRow(),
              ),
            ),
        ],
      ),
    );
  }

  TextField textFieldSearch(BuildContext context) {
    return TextField(
      controller: _searchController,
      onSubmitted: (value) => onSubmitAction(value),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: primaryUVColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => _searchController.clear(),
        ),
        labelText: AppLocalizations.of(context)!.search,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildPaginationButtonRow() {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 2.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (
              int i = setLowerLimit;
              i <= setUpperLimit && i <= totalPages && totalPages > 1;
              i++
            )
              OutlinedButton(
                onPressed: () {
                  paginationBehavior(i);
                  // optional: scroll to top when bottom pagination is pressed
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                style: i == currentPage
                    ? OutlinedButton.styleFrom(
                        backgroundColor: primaryUVColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      )
                    : OutlinedButton.styleFrom(
                        foregroundColor: primaryUVColor,
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                child: i == setUpperLimit
                    ? const Icon(Icons.arrow_forward)
                    : i == setLowerLimit && i > setMiddleSpace
                    ? const Icon(Icons.arrow_back)
                    : Text('$i'),
              ),
          ],
        ),
      ),
    );
  }
}

class BookList extends StatelessWidget {
  const BookList({super.key, required this.books});

  final List<BookPreview> books;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookView(biblioNumber: book.biblioNumber),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Image?>(
                      future: ImageService.fetchImageUrl(book.biblioNumber),
                      builder: (context, snapshot) {
                        if (snapshot.hasError || snapshot.data == null) {
                          return const SizedBox.shrink();
                        } else {
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (book.author.isNotEmpty)
                            Wrap(
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.byAuthor}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(book.author),
                              ],
                            ),
                          if (book.publishingDetails.isNotEmpty)
                            Wrap(
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.publishingDetails}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(book.publishingDetails),
                              ],
                            ),
                          if (book.locatedInLibraries > 0)
                            Text(
                              '${AppLocalizations.of(context)!.availability} ${book.locatedInLibraries} ${book.locatedInLibraries == 1 ? AppLocalizations.of(context)!.library.toLowerCase() : AppLocalizations.of(context)!.libraries.toLowerCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey),
          ],
        );
      },
    );
  }
}

class DropdownLibraries extends StatelessWidget {
  const DropdownLibraries({
    super.key,
    required TextEditingController libraryController,
    required this.widget,
  }) : _libraryController = libraryController;

  final TextEditingController _libraryController;
  final SearchView widget;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _libraryController,
      label: Text(AppLocalizations.of(context)!.library),
      leadingIcon: const Icon(Icons.location_city, color: primaryUVColor),
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: 'all',
          label: AppLocalizations.of(context)!.allLibraries,
        ),
        ...widget.controllersData.libraryEntries,
      ],
      menuHeight: 300,
      onSelected: (value) => widget.queryParams.library = value!,
      width: double.infinity,
    );
  }
}

class DropdownFilter extends StatelessWidget {
  const DropdownFilter({
    super.key,
    required TextEditingController filterController,
    required List<DropdownMenuEntry<String>> filterEntries,
    required this.widget,
  }) : _filterController = filterController,
       _filterEntries = filterEntries;

  final TextEditingController _filterController;
  final List<DropdownMenuEntry<String>> _filterEntries;
  final SearchView widget;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _filterController,
      label: Text(AppLocalizations.of(context)!.searchBy),
      leadingIcon: const Icon(Icons.filter_list, color: primaryUVColor),
      dropdownMenuEntries: _filterEntries,
      onSelected: (value) => widget.queryParams.searchBy = value!,
      enableFilter: false,
      requestFocusOnTap: false,
      width: double.infinity,
    );
  }
}

class DropdownItemType extends StatelessWidget {
  const DropdownItemType({
    super.key,
    required TextEditingController itemTypeController,
    required List<DropdownMenuEntry<String>> itemTypeEntries,
    required QueryParams queryParams,
  }) : _itemTypeController = itemTypeController,
       _itemTypeEntries = itemTypeEntries,
       _queryParams = queryParams;

  final TextEditingController _itemTypeController;
  final List<DropdownMenuEntry<String>> _itemTypeEntries;
  final QueryParams _queryParams;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _itemTypeController,
      label: Text(AppLocalizations.of(context)!.itemType),
      enableSearch: true,
      menuHeight: 300,
      leadingIcon: const Icon(Icons.category, color: primaryUVColor),
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: 'all',
          label: AppLocalizations.of(context)!.allItemTypes,
        ),
        ..._itemTypeEntries,
      ],
      initialSelection: _queryParams.itemType,
      onSelected: (value) => _queryParams.itemType = value!,
      width: double.infinity,
    );
  }
}
