class ImageModel {
  const ImageModel(this.title, this.url);
  final String title;
  final String url;

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      json['title'] as String,
      json['url'] as String,
    );
  }
}