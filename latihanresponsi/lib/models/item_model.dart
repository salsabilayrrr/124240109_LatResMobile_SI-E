// Model Data Generik untuk News, Blog, dan Reports
class ItemModel {
  final int id;
  final String title;
  final String author; // Sesuai catatan soal: diambil dari field news_site di API
  final String imageUrl;
  final String summary;
  final String publishedAt;
  final String url;
  final String category; // Penanda kategori: 'articles', 'blogs', atau 'reports'

  ItemModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.summary,
    required this.publishedAt,
    required this.url,
    required this.category,
  });

  // Mengubah data mentah Map/JSON dari internet menjadi objek ItemModel yang rapi
  factory ItemModel.fromJson(Map<String, dynamic> json, {String category = 'articles'}) {
    return ItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      // Catatan Soal: "author" yang tampil di chip/list adalah nilai field news_site
      author: json['news_site'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? '',
      summary: json['summary'] ?? 'Tidak ada ringkasan.',
      publishedAt: json['published_at'] ?? '',
      url: json['url'] ?? '',
      category: category,
    );
  }

  // Mengubah objek ItemModel kembali ke bentuk Map/JSON (berguna untuk simpan Favorit)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'news_site': author,
      'image_url': imageUrl,
      'summary': summary,
      'published_at': publishedAt,
      'url': url,
      'category': category,
    };
  }
}