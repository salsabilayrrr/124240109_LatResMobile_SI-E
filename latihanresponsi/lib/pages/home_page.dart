import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'list_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  // Fungsi untuk menangani proses Logout
  void _handleLogout(BuildContext context) async {
    // 1. Hapus status login dan username dari SharedPreferences
    await AuthService.logout();

    if (!context.mounted) return;

    // 2. Tendang keluar ke LoginPage dan bakar seluruh tumpukan halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // Widget pembantu (helper) pembuat kartu menu agar kode tidak berulang 3 kali
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String endpoint,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigasi ke Halaman List sesuai kategori yang dipilih
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListPage(
                title: title,
                endpoint: endpoint,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak Wadah Ikon Berwarna
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C5CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF5C5CFF),
                ),
              ),
              const SizedBox(width: 16),
              // Area Teks Judul dan Deskripsi Menu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, $username!'),
        automaticallyImplyLeading: false, // Menghilangkan tombol panah back di AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 1. Menu News (Mengakses endpoint: articles)
            _buildMenuCard(
              context: context,
              icon: Icons.newspaper,
              title: 'News',
              description:
                  'Get an overview of the latest SpaceFlight news, from various sources! Easily link your users to the right websites.',
              endpoint: 'articles',
            ),

            // 2. Menu Blog (Mengakses endpoint: blogs)
            _buildMenuCard(
              context: context,
              icon: Icons.menu_book,
              title: 'Blog',
              description:
                  'Blogs often provide a more detailed overview of launches and missions. A must-have for the serious spaceflight enthusiast.',
              endpoint: 'blogs',
            ),

            // 3. Menu Reports (Mengakses endpoint: reports)
            _buildMenuCard(
              context: context,
              icon: Icons.analytics_outlined,
              title: 'Reports',
              description:
                  'Space stations and other missions often publish their data. With SNAPI, you can include it in your app.',
              endpoint: 'reports',
            ),

            const SizedBox(height: 24),

            // Tombol Log Out Berwarna Merah Sesuai Soal
            ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}