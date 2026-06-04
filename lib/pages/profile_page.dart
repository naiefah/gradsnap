// 
// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _debugMessage = "Menunggu data...";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.appUser;
    final isLoading = auth.isLoading;

    // Debug: Update message based on state
    if (isLoading) {
      _debugMessage = "⏳ Sedang memuat data user...";
    } else if (user != null) {
      _debugMessage = "✅ Selamat datang, ${user.name}! (Role: ${user.role.displayName})";
    } else if (auth.firebaseUser != null && user == null) {
      _debugMessage = "⚠️ Firebase login sukses, tapi data user dari backend belum dimuat";
    } else {
      _debugMessage = "❌ Belum login";
    }

    // Jika belum login, tampilkan halaman login
    if (!auth.isLoggedIn || user == null) {
      return Scaffold(
        body: Column(
          children: [
            // Debug panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.amber.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🐛 DEBUG INFO:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_debugMessage),
                  if (auth.firebaseUser != null)
                    Text("Firebase UID: ${auth.firebaseUser!.uid}"),
                  if (auth.firebaseUser != null)
                    Text("Firebase Email: ${auth.firebaseUser!.email}"),
                ],
              ),
            ),
            const Expanded(child: LoginPage()),
          ],
        ),
      );
    }

    // Tampilkan pesan selamat datang di dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null && _debugMessage.contains("Selamat datang")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 $_debugMessage"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _debugMessage = "🔄 Refreshing data...";
          });
          if (user.firebaseUid.isNotEmpty) {
            await auth.loadUserFromBackend(user.firebaseUid);
          }
          setState(() {
            if (auth.appUser != null) {
              _debugMessage = "✅ Selamat datang, ${auth.appUser!.name}!";
            }
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Debug Panel (untuk testing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🐛 DEBUG INFO:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(_debugMessage),
                    const SizedBox(height: 4),
                    Text("User ID: ${user.id}"),
                    Text("Firebase UID: ${user.firebaseUid}"),
                    Text("Role: ${user.role.displayName}"),
                    Text("Phone: ${user.phone ?? 'Not set'}"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Welcome Card
              Card(
                margin: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.celebration, size: 48, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        "Selamat Datang!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Halo ${user.name}, senang bertemu denganmu!",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Profile Info
              CircleAvatar(
                radius: 60,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.displayName,
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person, 'Name', user.name),
                      const Divider(),
                      _buildInfoRow(Icons.email, 'Email', user.email),
                      const Divider(),
                      _buildInfoRow(Icons.phone, 'Phone', user.phone ?? 'Not set'),
                      const Divider(),
                      _buildInfoRow(Icons.location_on, 'Location', user.location ?? 'Not set'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: auth.isLoading ? null : () async {
                  await auth.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/main');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}