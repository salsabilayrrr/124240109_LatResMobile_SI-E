import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Pengendali teks untuk menangkap ketikan pengguna
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Bersihkan controller dari memori HP saat halaman ditutup
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi saat tombol Daftar ditekan
  void _handleRegister() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Validasi: tidak boleh ada kolom yang kosong
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simpan akun ke SharedPreferences melalui AuthService
    await AuthService.register(username, password);

    if (!mounted) return;

    // Tampilkan notifikasi hijau tanda sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran Berhasil! Silakan Login.'),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke halaman Login
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul Halaman
              const Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Field Input Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field Input Password
              TextField(
                controller: _passwordController,
                obscureText: true, // Menyembunyikan karakter jadi titik-titik
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}