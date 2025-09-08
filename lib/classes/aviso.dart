class Aviso {
  final String imagen;
  final String enlace;

  Aviso({required this.imagen, required this.enlace});

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(imagen: json['imagen'], enlace: json['enlace']);
  }
}
