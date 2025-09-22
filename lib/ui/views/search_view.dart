import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:flutter/material.dart';
import 'package:catbiblio_app/services/svc/search.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = setLowerLimit; i <= setUpperLimit && i <= totalPages; i++)
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
              SizedBox(height: 8),
              Text(
                '$totalRecords ${AppLocalizations.of(context)!.totalResults}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.grey),
              ...books.map((book) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookView(biblioNumber: book.biblioNumber),
                          ),
                        );
                      },
                      title: Text(
                        book.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${AppLocalizations.of(context)!.byAuthor}: ${book.author}\n${AppLocalizations.of(context)!.publishingDetails}: ${book.publishingDetails} \n${AppLocalizations.of(context)!.availability}: 1 biblioteca',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      contentPadding: EdgeInsets.all(0),
                      minVerticalPadding: 0,
                    ),
                    Divider(color: Colors.grey),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = setLowerLimit; i <= setUpperLimit; i++)
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
            ],
          ),
        ),
      ),
    );
  }
}
