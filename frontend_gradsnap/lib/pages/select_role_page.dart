// lib/pages/select_role_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'home_page.dart';

class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  State<SelectRolePage> createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  UserRole? _selectedRole;
  bool _isLoading = false;
  
  final _formKey = GlobalKey<FormState>();
  final _priceRangeController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<File> _portfolioImages = [];
  final ImagePicker _picker = ImagePicker();
  
  @override
  void dispose() {
    _priceRangeController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _portfolioImages = images.map((e) => File(e.path)).toList();
      });
    }
  }
  
  Future<void> _saveRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih role terlebih dahulu")),
      );
      return;
    }
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Customer: langsung simpan
    if (_selectedRole == UserRole.customer) {
      setState(() => _isLoading = true);
      final success = await auth.updateUserRole(UserRole.customer);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil menjadi Customer!"), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
      setState(() => _isLoading = false);
      return;
    }
    
    // Validasi form untuk MUA/Photographer
    if (!_formKey.currentState!.validate()) return;
    if (_portfolioImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload minimal 1 foto portfolio")),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Menyimpan data vendor..."),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final success = await auth.upgradeToVendor(
        role: _selectedRole!,
        priceRange: _priceRangeController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        portfolioImages: _portfolioImages,
      ).timeout(const Duration(seconds: 60), onTimeout: () => throw Exception('Timeout, coba lagi'));
      
      if (mounted) Navigator.pop(context); // Tutup dialog
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selamat! Anda sekarang menjadi ${_selectedRole!.displayName}!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan data. Coba lagi."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isVendorRole = _selectedRole == UserRole.mua || _selectedRole == UserRole.photographer;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadi MUA / Photographer"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih Peran", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Pilih peran yang ingin Anda daftarkan", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              _buildRoleCard(
                title: "Makeup Artist (MUA)",
                description: "Menawarkan jasa makeup",
                icon: Icons.brush,
                color: Colors.pink,
                role: UserRole.mua,
                isSelected: _selectedRole == UserRole.mua,
                onTap: () => setState(() => _selectedRole = UserRole.mua),
              ),
              
              const SizedBox(height: 12),
              
              _buildRoleCard(
                title: "Photographer",
                description: "Menawarkan jasa fotografi",
                icon: Icons.camera_alt,
                color: Colors.purple,
                role: UserRole.photographer,
                isSelected: _selectedRole == UserRole.photographer,
                onTap: () => setState(() => _selectedRole = UserRole.photographer),
              ),
              
              if (isVendorRole) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Dengan mengisi data ini, customer akan lebih percaya dengan jasa Anda!",
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Informasi Profil Vendor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Alamat / Lokasi",
                    hintText: "Masukkan alamat lengkap",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? "Alamat tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _priceRangeController,
                  decoration: const InputDecoration(
                    labelText: "Kisaran Harga",
                    hintText: "Contoh: Rp 500.000 - Rp 1.500.000",
                    prefixIcon: Icon(Icons.price_check),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? "Kisaran harga tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Deskripsi / Keahlian",
                    hintText: "Ceritakan tentang keahlian Anda",
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? "Deskripsi tidak boleh kosong" : null,
                ),
                const SizedBox(height: 16),
                
                const Text("Portfolio / Hasil Karya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Upload foto hasil karya Anda (minimal 1 foto)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (_portfolioImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _portfolioImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(_portfolioImages[index], width: 84, height: 84, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _portfolioImages.removeAt(index)),
                                        child: Container(
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ListTile(
                        leading: const Icon(Icons.add_photo_alternate),
                        title: Text(_portfolioImages.isEmpty ? "Tambah Foto Portfolio" : "Tambah Foto Lagi"),
                        onTap: _pickImages,
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text("Daftar Sekarang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required UserRole role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? color : Colors.black87)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}