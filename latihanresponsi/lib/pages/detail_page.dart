import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/item_model.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final ItemModel item;

  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FavoriteService _favService = FavoriteService();

  @override
  void initState() {
    super.initState();
    // Memasang pendengar (listener) agar status hati otomatis sinkron jika ada perubahan
    _favService.addListener(_onFavChanged);
  }

  @override
  void dispose() {
    // Melepas pendengar saat keluar dari halaman untuk mencegah kebocoran memori
    _favService.removeListener(_onFavChanged);
    super.dispose();
  }

  void _onFavChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Fungsi untuk membuka link website resmi menggunakan url_launcher
  void _openWebsite() async {
    final String urlString = widget.item.url;
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan web tidak tersedia untuk artikel ini.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(urlString);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka browser.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat membuka link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleToggleFavorite() async {
    final bool isAdded = await _favService.toggleFavorite(widget.item);

    if (!mounted) return;

    // Menampilkan SnackBar konfirmasi sesuai ketentuan soal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdded ? 'Ditambahkan ke favorite' : 'Dihapus dari favorite',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: isAdded ? Colors.black87 : Colors.grey.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah item ini sudah menjadi favorit
    final bool isFav = _favService.isFavorite(widget.item);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          // Tombol Ikon Hati di AppBar (Ketentuan Soal: Outline jika belum, Merah jika sudah)
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
            tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            onPressed: _handleToggleFavorite,
          ),
        ],
      ),
      // Tombol Mengambang (Floating Action Button) untuk Buka Web Sesuai Soal
      floatingActionButton: FloatingActionButton(
        tooltip: 'Buka Web',
        backgroundColor: const Color(0xFF5C5CFF).withOpacity(0.2),
        elevation: 1,
        onPressed: _openWebsite,
        child: const Icon(
          Icons.open_in_new,
          color: Color(0xFF5C5CFF),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Besar dengan Error Handling
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                widget.item.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Konten Teks Detail
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Judul Artikel Lengkap (Tebal)
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Nama Author / News Site
                  Text(
                    widget.item.author,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 4. Tanggal Publish
                  Text(
                    widget.item.publishedAt,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 12),

                  // 5. Teks Summary / Ringkasan Berita
                  Text(
                    widget.item.summary.isNotEmpty
                        ? widget.item.summary
                        : 'Tidak ada ringkasan yang tersedia untuk artikel ini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}