class QueryParams {
  String tipoBusqueda;
  String biblioteca;
  String cadenaDeBusqueda;

  QueryParams({
    required this.tipoBusqueda,
    required this.biblioteca,
    required this.cadenaDeBusqueda,
  });

  @override
  String toString() {
    return 'QueryParams{tipoBusqueda: $tipoBusqueda, biblioteca: $biblioteca, cadenaDeBusqueda: $cadenaDeBusqueda}';
  }
}
