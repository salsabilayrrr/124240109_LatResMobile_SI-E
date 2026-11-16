import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/item_model.dart';

class ApiService {
  // Alamat dasar (Base URL) API Spaceflight News v4
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  // 1. Fungsi untuk mengambil daftar artikel (News, Blog, atau Reports)
  static Future<List<ItemModel>> getItems(String category) async {
    // Tambahkan ?limit=30 agar data yang diambil cukup banyak untuk filter dan scroll
    final url = Uri.parse('$baseUrl/$category/?limit=30');

    try {
      // Mengirim permintaan GET ke server
      final response = await http.get(url);

      // Status 200 artinya request sukses diterima server
      if (response.statusCode == 200) {
        // Mengubah string mentah JSON menjadi Map Dart
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Mengambil daftar data di dalam key "results"
        final List<dynamic> results = data['results'] ?? [];

        // Mengubah tiap butir data JSON menjadi objek ItemModel
        return results
            .map((item) => ItemModel.fromJson(item, category: category))
            .toList();
      } else {
        throw Exception(
          'Gagal memuat data dari server (Kode: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  // 2. Fungsi untuk mengambil detail satu artikel berdasarkan ID
  static Future<ItemModel> getItemDetail(String category, int id) async {
    final url = Uri.parse('$baseUrl/$category/$id/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ItemModel.fromJson(data, category: category);
      } else {
        throw Exception(
          'Gagal memuat detail artikel (Kode: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan saat memuat detail: $e');
    }
  }
}
