import 'package:flutter/material.dart';
import 'package:grad_snap/models/user_model.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'select_role_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.appUser;

    if (!auth.isLoggedIn || user == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: user.photoUrl == null || user.photoUrl!.isEmpty
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // Name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Email
            Text(
              user.email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRoleColor(user.role),
                  width: 0.5,
                ),
              ),
              child: Text(
                user.role.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRoleColor(user.role),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFFD4AF37)),
                    title: const Text("Nama"),
                    subtitle: Text(user.name),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFFD4AF37)),
                    title: const Text("Email"),
                    subtitle: Text(user.email),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Color(0xFFD4AF37)),
                    title: const Text("Nomor HP"),
                    subtitle: Text(
                      user.phone ?? "Belum diisi",
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFFD4AF37)),
                    title: const Text("Lokasi"),
                    subtitle: Text(
                      user.location ?? "Belum diisi",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TOMBOL JADI MUA / PHOTOGRAPHER (hanya untuk customer)
            if (user.role == UserRole.customer) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      color: Color(0xFFD4AF37),
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    "Jadi MUA / Photographer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    "Mulai transaksi jual jasa Anda",
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectRolePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // CARD UNTUK VENDOR (MUA/PHOTOGRAPHER) - LANGSUNG TERVERIFIKASI
            if (user.role == UserRole.mua || user.role == UserRole.photographer) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    "Vendor Terverifikasi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Anda terdaftar sebagai ${user.role.displayName}",
                    style: const TextStyle(fontSize: 13, color: Colors.green),
                  ),
                  trailing: const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Admin Card (khusus admin)
            if (user.role == UserRole.admin) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.purple,
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    "Administrator",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    "Akses penuh ke platform",
                    style: TextStyle(fontSize: 13, color: Colors.purple),
                  ),
                  trailing: const Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await auth.signOut();

                  if (context.mounted) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/main',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function untuk mendapatkan warna role
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.mua:
        return Colors.pink;
      case UserRole.photographer:
        return Colors.purple;
      case UserRole.admin:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}