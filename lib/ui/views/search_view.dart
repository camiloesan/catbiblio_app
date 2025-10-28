import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/controllers_data.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:catbiblio_app/ui/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/search.dart';
import 'package:catbiblio_app/services/images.dart';
import 'package:skeletonizer/skeletonizer.dart';

part '../controllers/search_controller.dart';

const Color primaryUVColor = Color.fromARGB(255, 24, 82, 157);

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
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/images/head-icon.png', height: 40),
        ),
      ),
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownItemType(
                              itemTypeController: _itemTypeController,
                              itemTypeEntries:
                                  widget.controllersData.itemTypeEntries,
                              queryParams: widget.queryParams,
                              maxWidth: constraints.maxWidth,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownLibraries(
                              libraryEntries:
                                  widget.controllersData.libraryEntries,
                              widget: widget,
                              maxWidth: constraints.maxWidth,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return DropdownFilter(
                              filterController: _filterController,
                              filterEntries: _filterEntries,
                              widget: widget,
                              maxWidth: constraints.maxWidth,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFieldSearchWidget(
                          searchController: _searchController,
                          isSearchable: true,
                          onSubmitted: onSubmitAction,
                          clearSearchController: clearSearchController,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  PaginationButtonRow(
                    paginationBehavior: paginationBehavior,
                    setLowerLimit: setLowerLimit,
                    setUpperLimit: setUpperLimit,
                    totalPages: totalPages,
                    currentPage: currentPage,
                    setMiddleSpace: setMiddleSpace,
                    scrollController: _scrollController,
                  ),
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
          BookList(
            books: books,
            isPageLoading: isPageLoading,
            isInitialRequestLoading: isInitialRequestLoading,
          ),

          // Bottom pagination
          if (!isPageLoading && books.length > 5)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: PaginationButtonRow(
                  paginationBehavior: paginationBehavior,
                  setLowerLimit: setLowerLimit,
                  setUpperLimit: setUpperLimit,
                  totalPages: totalPages,
                  currentPage: currentPage,
                  setMiddleSpace: setMiddleSpace,
                  scrollController: _scrollController,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PaginationButtonRow extends StatelessWidget {
  const PaginationButtonRow({
    super.key,
    required paginationBehavior,
    required setLowerLimit,
    required setUpperLimit,
    required totalPages,
    required currentPage,
    required setMiddleSpace,
    required ScrollController scrollController,
  }) : _paginationBehavior = paginationBehavior,
       _setLowerLimit = setLowerLimit,
       _setUpperLimit = setUpperLimit,
       _totalPages = totalPages,
       _currentPage = currentPage,
       _setMiddleSpace = setMiddleSpace,
       _scrollController = scrollController;
  final Function(int) _paginationBehavior;
  final int _setLowerLimit;
  final int _setUpperLimit;
  final int _totalPages;
  final int _currentPage;
  final int _setMiddleSpace;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 2.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (
              int i = _setLowerLimit;
              i <= _setUpperLimit && i <= _totalPages && _totalPages > 1;
              i++
            )
              OutlinedButton(
                onPressed: () {
                  _paginationBehavior(i);
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                style: i == _currentPage
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
                child: i == _setUpperLimit
                    ? const Icon(Icons.arrow_forward)
                    : i == _setLowerLimit && i > _setMiddleSpace
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
  const BookList({
    super.key,
    required this.books,
    required this.isPageLoading,
    required this.isInitialRequestLoading,
  });

  final List<BookPreview> books;
  final bool isPageLoading;
  final bool isInitialRequestLoading;

  @override
  Widget build(BuildContext context) {
    if (isPageLoading || isInitialRequestLoading) {
      return SliverList.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Skeletonizer(
                enabled: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '---------------------------------',
                              style: const TextStyle(fontSize: 25),
                            ),
                            Text(
                              '---------------------------',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              '-------------------------------',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              '---------------------',
                              style: const TextStyle(fontSize: 18),
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

class TextFieldSearchWidget extends StatelessWidget {
  const TextFieldSearchWidget({
    super.key,
    required TextEditingController searchController,
    required bool isSearchable,
    required Function(String) onSubmitted,
    required VoidCallback clearSearchController,
  }) : _searchController = searchController,
       _isSearchable = isSearchable,
       _onSubmitted = onSubmitted,
       _clearSearchController = clearSearchController;

  final TextEditingController _searchController;
  final bool _isSearchable;
  final Function(String) _onSubmitted;
  final VoidCallback _clearSearchController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onSubmitted: (value) => _onSubmitted(value),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon: _isSearchable
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _clearSearchController(),
              )
            : null,
        labelText: AppLocalizations.of(context)!.search,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class DropdownLibraries extends StatelessWidget {
  const DropdownLibraries({
    super.key,
    required this.libraryEntries,
    required this.widget,
    required double maxWidth,
  }) : _maxWidth = maxWidth;

  final List<DropdownMenuEntry<String>> libraryEntries;
  final SearchView widget;
  final double _maxWidth;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      label: Text(AppLocalizations.of(context)!.library),
      leadingIcon: const Icon(Icons.location_city, color: primaryUVColor),
      initialSelection: widget.queryParams.library,
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: 'all',
          label: AppLocalizations.of(context)!.allLibraries,
        ),
        ...libraryEntries,
      ],
      menuHeight: 300,
      onSelected: (value) => widget.queryParams.library = value!,
      width: _maxWidth,
    );
  }
}

class DropdownFilter extends StatelessWidget {
  const DropdownFilter({
    super.key,
    required TextEditingController filterController,
    required List<DropdownMenuEntry<String>> filterEntries,
    required this.widget,
    required double maxWidth,
  }) : _filterController = filterController,
       _filterEntries = filterEntries,
       _maxWidth = maxWidth;

  final TextEditingController _filterController;
  final List<DropdownMenuEntry<String>> _filterEntries;
  final SearchView widget;
  final double _maxWidth;

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
      width: _maxWidth,
    );
  }
}

class DropdownItemType extends StatelessWidget {
  const DropdownItemType({
    super.key,
    required TextEditingController itemTypeController,
    required List<DropdownMenuEntry<String>> itemTypeEntries,
    required QueryParams queryParams,
    required double maxWidth,
  }) : _itemTypeController = itemTypeController,
       _itemTypeEntries = itemTypeEntries,
       _queryParams = queryParams,
       _maxWidth = maxWidth;

  final TextEditingController _itemTypeController;
  final List<DropdownMenuEntry<String>> _itemTypeEntries;
  final QueryParams _queryParams;
  final double _maxWidth;

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
      width: _maxWidth,
    );
  }
}
