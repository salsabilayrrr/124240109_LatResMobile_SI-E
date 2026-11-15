import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';
import 'auth_service.dart';

class FavoriteService extends ChangeNotifier {
  // Pola Singleton: Memastikan hanya ada 1 wujud FavoriteService di seluruh aplikasi
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  // Daftar keranjang penampung artikel favorit di memori aktif
  final List<ItemModel> _favorites = [];

  // Getter agar halaman lain bisa membaca daftar favorit tanpa bisa merusaknya langsung
  List<ItemModel> get favorites => List.unmodifiable(_favorites);

  // Kunci Unik Pengaman: Menggabungkan kategori dan ID agar tidak saling bentrok
  // Contoh: ID 12 di 'articles' kuncinya "articles_12", di 'blogs' jadi "blogs_12"
  String _getItemKey(ItemModel item) => '${item.category}_${item.id}';

  // 1. Inisialisasi: Membaca data favorit dari SharedPreferences saat aplikasi jalan
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String username = await AuthService.getLoggedUsername();

    // Simpan favorit per user (contoh key: "favorites_rahman")
    final String storageKey = 'favorites_$username';
    final List<String> rawList = prefs.getStringList(storageKey) ?? [];

    _favorites.clear();
    for (String itemStr in rawList) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(itemStr);
        _favorites.add(ItemModel.fromJson(jsonMap, category: jsonMap['category'] ?? 'articles'));
      } catch (e) {
        debugPrint('Gagal membaca satu item favorit: $e');
      }
    }

    // Bunyikan bel (notifyListeners) agar semua halaman tahu data favorit sudah siap
    notifyListeners();
  }

  // 2. Fungsi Cek: Apakah artikel ini sedang difavoritkan?
  bool isFavorite(ItemModel item) {
    return _favorites.any((fav) => _getItemKey(fav) == _getItemKey(item));
  }

  // 3. Fungsi Toggle (Tambah / Hapus) dari Halaman Detail
  // Mengembalikan true jika ditambahkan, false jika dihapus (untuk membedakan pesan SnackBar)
  Future<bool> toggleFavorite(ItemModel item) async {
    final bool alreadyFav = isFavorite(item);

    if (alreadyFav) {
      // Jika sudah ada -> Hapus dari keranjang
      _favorites.removeWhere((fav) => _getItemKey(fav) == _getItemKey(item));
    } else {
      // Jika belum ada -> Masukkan ke keranjang
      _favorites.add(item);
    }

    // Simpan perubahan ke SharedPreferences HP
    await _saveToPrefs();

    // Bunyikan lonceng agar Halaman Detail & Halaman Favorit otomatis update live
    notifyListeners();

    return !alreadyFav; // true = baru ditambahkan, false = baru dihapus
  }

  // 4. Fungsi Hapus Khusus (dipanggil saat klik ikon hati di Halaman Favorit)
  Future<void> removeFavorite(ItemModel item) async {
    _favorites.removeWhere((fav) => _getItemKey(fav) == _getItemKey(item));
    await _saveToPrefs();
    notifyListeners();
  }

  // Fungsi internal untuk menulis daftar ke memori HP
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String username = await AuthService.getLoggedUsername();
    final String storageKey = 'favorites_$username';

    // Mengubah setiap ItemModel menjadi teks JSON lalu dikumpulkan jadi List<String>
    final List<String> rawList = _favorites.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await prefs.setStringList(storageKey, rawList);
  }
}