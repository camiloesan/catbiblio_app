part of '../views/book_view.dart';

abstract class BookController extends State<BookView> {
  late Future<BibliosDetails> _bibliosDetailsFuture;
  BibliosDetails bibliosDetails = BibliosDetails(title: '', author: '');

  @override
  void initState() {
    super.initState();
    _bibliosDetailsFuture = BibliosDetailsService.getBibliosDetails(widget.biblioNumber);
  }
}
