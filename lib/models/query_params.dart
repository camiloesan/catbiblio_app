import 'package:flutter/widgets.dart';

class QueryParams {
  String tipoBusqueda;
  String biblioteca;
  String cadenaDeBusqueda;

  QueryParams({
    required this.tipoBusqueda,
    required this.biblioteca,
    required this.cadenaDeBusqueda,
  });
}