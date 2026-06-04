// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _debugMessage = "";
  
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    // Jika sudah login, kembali ke profile (akan dihandle oleh ProfilePage)
    if (auth.isLoggedIn) {
      return const SizedBox.shrink();
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Debug Panel
                  if (_debugMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _debugMessage,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Grad-Snap',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Capture your graduation moments',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Google Sign In Button
                  auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                _debugMessage = "⏳ Memproses login Google...";
                              });
                              
                              await auth.signInWithGoogle();
                              
                              setState(() {
                                if (auth.isLoggedIn && auth.appUser != null) {
                                  _debugMessage = "✅ Berhasil login! Selamat datang ${auth.appUser!.name}";
                                  // Tunggu sebentar lalu pindah halaman
                                  Future.delayed(const Duration(seconds: 1), () {
                                    if (mounted) {
                                      Navigator.pushReplacementNamed(context, '/profile');
                                    }
                                  });
                                } else if (auth.firebaseUser != null && auth.appUser == null) {
                                  _debugMessage = "⚠️ Login Firebase berhasil, tapi gagal memuat data user dari database";
                                } else {
                                  _debugMessage = "❌ Login gagal atau dibatalkan";
                                }
                              });
                            },
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  Text(
                    'By continuing, you agree to our Terms of Service',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}