// pages/add_service_package_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/vendor_provider.dart';
import '../providers/auth_provider.dart';

class AddServicePackagePage extends StatefulWidget {
  const AddServicePackagePage({super.key});

  @override
  State<AddServicePackagePage> createState() => _AddServicePackagePageState();
}

class _AddServicePackagePageState extends State<AddServicePackagePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _inclusionController = TextEditingController();
  
  List<String> _inclusions = [];
  File? _imageFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _inclusionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _addInclusion() {
    if (_inclusionController.text.isNotEmpty) {
      setState(() {
        _inclusions.add(_inclusionController.text);
        _inclusionController.clear();
      });
    }
  }

  void _removeInclusion(int index) {
    setState(() {
      _inclusions.removeAt(index);
    });
  }

  Future<void> _submitPackage() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_inclusions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal tambahkan 1 layanan yang termasuk'), 
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isUploading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    
    // ✅ AMBIL USER ID DARI appUser
    final currentUser = authProvider.appUser;
    
    // ✅ CEK APAKAH USER VALID DAN MEMILIKI ID
    if (currentUser == null) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan, silakan login kembali'), 
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // ✅ AMBIL USER ID DARI MODEL USER
    final vendorId = currentUser.id;
    
    if (vendorId == null || vendorId == 0) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Vendor tidak valid'), 
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    debugPrint("✅ Vendor ID: $vendorId");
    debugPrint("✅ Vendor Name: ${currentUser.name}");
    
    String? imageUrl;
    
    // Upload image jika ada
    if (_imageFile != null) {
      imageUrl = await vendorProvider.uploadPackageImage(_imageFile!, vendorId);
      
      if (imageUrl == null && mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal upload gambar'), 
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    final success = await vendorProvider.addPackage(
      vendorId: vendorId,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      duration: _durationController.text,
      inclusions: _inclusions,
      imageUrl: imageUrl,
    );
    
    setState(() => _isUploading = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package berhasil ditambahkan'), 
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan package'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CEK APAKAH USER LOGIN DAN MEMILIKI ROLE YANG SESUAI
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.appUser;
    
    // Jika belum login
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Package Layanan'),
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    // Jika bukan MUA atau Photographer
    if (!currentUser.isMUA && !currentUser.isPhotographer) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tambah Package Layanan'),
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Anda harus menjadi MUA atau Photographer\ndulu untuk menambahkan package',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Package Layanan'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Vendor
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vendor: ${currentUser.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'ID: ${currentUser.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentUser.isMUA 
                            ? Colors.pink.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentUser.isMUA ? 'MUA' : 'Photographer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: currentUser.isMUA ? Colors.pink : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Photo Upload Section
              _buildPhotoUploadSection(),
              const SizedBox(height: 24),
              
              // Form Fields
              _buildTextField(
                label: 'Nama Package',
                hint: 'Contoh: Makeup Wisuda Premium',
                controller: _nameController,
                icon: Icons.card_giftcard,
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                label: 'Harga',
                hint: 'Masukkan harga dalam Rupiah',
                controller: _priceController,
                keyboardType: TextInputType.number,
                icon: Icons.money,
                prefixText: 'Rp ',
              ),
              const SizedBox(height: 20),
              
              _buildTextField(
                label: 'Durasi',
                hint: 'Contoh: 3 jam, 1 hari, 2 sesi',
                controller: _durationController,
                icon: Icons.access_time,
              ),
              const SizedBox(height: 20),
              
              _buildDescriptionField(),
              const SizedBox(height: 20),
              
              _buildInclusionsSection(),
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Package',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_imageFile!, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload photo',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG, max 5MB',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label harus diisi';
            }
            if (keyboardType == TextInputType.number) {
              if (double.tryParse(value) == null) {
                return 'Harga harus berupa angka';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Deskripsikan package layanan Anda secara detail...',
            hintMaxLines: 3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInclusionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yang Termasuk dalam Package',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _inclusionController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Makeup, Hairdo, Softlens',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onFieldSubmitted: (_) => _addInclusion(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addInclusion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // List of inclusions
        if (_inclusions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Layanan yang termasuk:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ..._inclusions.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String inclusion = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            inclusion,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeInclusion(idx),
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red[300],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Belum ada layanan yang ditambahkan. Klik tombol + untuk menambahkan.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitPackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isUploading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Tambah Package',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}