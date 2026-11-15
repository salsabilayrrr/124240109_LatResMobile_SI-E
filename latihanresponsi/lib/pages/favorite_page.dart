import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/favorite_service.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favService = FavoriteService();

  @override
  void initState() {
    super.initState();
    // Memasang pendengar: setiap kali ada perubahan data favorit, layar ini langsung me-refresh diri
    _favService.addListener(_onFavoriteChanged);
  }

  @override
  void dispose() {
    // Melepas pendengar saat halaman ditutup
    _favService.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  void _onFavoriteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil seluruh daftar favorit (gabungan News, Blog, dan Reports)
    final List<ItemModel> favorites = _favService.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
      ),
      // Kondisi 1: Jika keranjang favorit masih kosong
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada artikel favorit.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Buka detail artikel lalu tekan ikon hati untuk menambahkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          // Kondisi 2: Jika ada artikel favorit, tampilkan sebagai barisan kartu
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final ItemModel item = favorites[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    // 1. Thumbnail Gambar dengan Error Handling
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 2. Judul Berita (Maksimal 2 Baris)
                    title: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    // 3. Nama Author & Label Kategori di bawah judul
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${item.author} • [${item.category.toUpperCase()}]',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // 4. Ikon Hati Merah di sebelah kanan (Trailing) untuk menghapus langsung (Ketentuan Soal)
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      tooltip: 'Hapus dari Favorit',
                      onPressed: () async {
                        // Hapus artikel dari daftar favorit
                        await _favService.removeFavorite(item);

                        if (!context.mounted) return;

                        // SnackBar pemberitahuan bahwa artikel telah dihapus
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dihapus dari favorite'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                    // 5. Klik pada kartu -> Membuka Halaman Detail Artikel
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(item: item),
                        ),
                      ).then((_) {
                        // Penjaga Kepulangan: Refresh layar seketika saat kembali
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}