import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Kunci (Key) unik sebagai penanda laci penyimpanan di SharedPreferences
  static const String _keyRegUser = 'registered_username';
  static const String _keyRegPass = 'registered_password';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLoggedUser = 'logged_username';

  // 1. FUNGSI REGISTER: Menyimpan username dan password baru ke memori HP
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegUser, username);
    await prefs.setString(_keyRegPass, password);
    return true;
  }

  // 2. FUNGSI LOGIN: Memeriksa kecocokan data input dengan akun yang terdaftar
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final String? registeredUser = prefs.getString(_keyRegUser);
    final String? registeredPass = prefs.getString(_keyRegPass);

    // Cek apakah akun sudah pernah didaftarkan dan password-nya cocok
    if (registeredUser != null &&
        registeredPass != null &&
        registeredUser == username &&
        registeredPass == password) {
      // Jika cocok, catat status login = true dan catat siapa username-nya
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyLoggedUser, username);
      return true; // Login Berhasil
    }

    return false; // Login Gagal (belum terdaftar atau password salah)
  }

  // 3. FUNGSI LOGOUT: Mengubah status login kembali menjadi false
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyLoggedUser);
  }

  // 4. FUNGSI AMBIL USERNAME AKTIF: Mengetahui siapa yang sedang login
  static Future<String> getLoggedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLoggedUser) ?? '';
  }

  // 5. FUNGSI CEK STATUS LOGIN: Mengetahui apakah pengguna masih dalam sesi login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}