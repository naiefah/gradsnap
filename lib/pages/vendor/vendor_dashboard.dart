// lib/pages/vendor/vendor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/user_model.dart';
import '../../models/service_package.dart';
import 'add_package_page.dart';
import 'vendor_orders_page.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int _selectedIndex = 0;
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
  
  if (auth.appUser != null) {
    debugPrint("🟢 Loading packages for vendor: ${auth.appUser!.id}");
    await vendorProvider.loadPackages(auth.appUser!.id);
    debugPrint("🟢 Packages loaded: ${vendorProvider.packages.length}");
    debugPrint("🟢 Packages data: ${vendorProvider.packages}");
    
    // Refresh UI
    setState(() {});
  }
}
  
  

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.appUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login terlebih dahulu")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard ${user.role.displayName}"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildPackagesTab(),
          const VendorOrdersPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD4AF37),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Paket Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Pesanan',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPackagePage(vendorId: user.id),
                  ),
                );
                if (result == true) {
                  await Provider.of<VendorProvider>(context, listen: false)
                      .loadPackages(user.id);
                }
              },
              backgroundColor: const Color(0xFFD4AF37),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPackagesTab() {
    final vendorProvider = Provider.of<VendorProvider>(context);
    final packages = vendorProvider.packages;

    if (vendorProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "Belum ada paket",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tekan tombol + untuk menambahkan paket",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return _buildPackageCard(package);
      },
    );
  }

  Widget _buildPackageCard(ServicePackage package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_camera, size: 32, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.duration,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: package.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    package.isActive ? "Aktif" : "Nonaktif",
                    style: TextStyle(
                      color: package.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              package.description,
              style: TextStyle(color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    package.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showEditDialog(package),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit"),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(package),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text("Hapus", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ServicePackage package) {
    final nameController = TextEditingController(text: package.name);
    final descController = TextEditingController(text: package.description);
    final priceController = TextEditingController(text: package.price.toString());
    final durationController = TextEditingController(text: package.duration);
    final inclusionsController = TextEditingController(text: package.inclusions.join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Paket"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Paket")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Deskripsi"), maxLines: 3),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
              TextField(controller: durationController, decoration: const InputDecoration(labelText: "Durasi (contoh: 3 jam)")),
              TextField(controller: inclusionsController, decoration: const InputDecoration(labelText: "Termasuk (pisahkan dengan koma)")),
              Row(
                children: [
                  const Text("Status Aktif"),
                  const SizedBox(width: 16),
                  Switch(
                    value: package.isActive,
                    onChanged: (value) {
                      // Handle switch
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final updatedPackage = package.copyWith(
                name: nameController.text,
                description: descController.text,
                price: double.parse(priceController.text),
                duration: durationController.text,
                inclusions: inclusionsController.text.split(',').map((e) => e.trim()).toList(),
              );
              final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
              final success = await vendorProvider.updatePackage(updatedPackage);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Paket berhasil diupdate")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ServicePackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Paket"),
        content: Text("Yakin ingin menghapus paket '${package.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
              final success = await vendorProvider.deletePackage(package.id, package.vendorId);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Paket berhasil dihapus")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}