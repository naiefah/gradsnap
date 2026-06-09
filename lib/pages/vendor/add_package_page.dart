// lib/pages/vendor/add_package_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/vendor_provider.dart';

class AddPackagePage extends StatefulWidget {
  final int vendorId;

  const AddPackagePage({super.key, required this.vendorId});

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _inclusionsController = TextEditingController();
  
  // Untuk durasi
  TimeOfDay _selectedDuration = const TimeOfDay(hour: 3, minute: 0);
  
  // Untuk foto
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _inclusionsController.dispose();
    super.dispose();
  }

  // Pilih gambar dari gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Pilih durasi dengan TimePicker
  Future<void> _selectDuration() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDuration,
      helpText: 'Pilih Durasi',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    
    if (picked != null && picked != _selectedDuration) {
      setState(() {
        _selectedDuration = picked;
      });
    }
  }

  // Format durasi menjadi string
  String get formattedDuration {
    final hour = _selectedDuration.hour;
    final minute = _selectedDuration.minute;
    
    if (hour == 0 && minute > 0) {
      return '$minute menit';
    } else if (hour > 0 && minute == 0) {
      return '$hour jam';
    } else if (hour > 0 && minute > 0) {
      return '$hour jam $minute menit';
    } else {
      return '3 jam';
    }
  }

  // Upload gambar ke server
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${VendorProvider.BASE_URL}/gradsnap_backend/vendor/upload_package_image.php"),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
      request.fields['vendor_id'] = widget.vendorId.toString();
      
      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      
      if (jsonData['status'] == 'success') {
        return jsonData['url'];
      }
      return null;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;
    
    final price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harga harus berupa angka"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Upload image dulu jika ada
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage();
    }

    // Proses inclusions
    final inclusionsText = _inclusionsController.text.trim();
    final List<String> inclusions = inclusionsText.isEmpty
        ? []
        : inclusionsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    
    final success = await vendorProvider.addPackage(
      vendorId: widget.vendorId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: price,
      duration: formattedDuration,
      inclusions: inclusions,
      imageUrl: imageUrl,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paket berhasil ditambahkan!"), backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menambahkan paket"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Paket Baru"),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Paket",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Upload Foto
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ListTile(
                      leading: Icon(Icons.photo_library, color: const Color(0xFFD4AF37)),
                      title: Text(_selectedImage == null ? "Upload Foto Paket" : "Ganti Foto"),
                      subtitle: const Text("JPG, PNG, maks 5MB"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _pickImage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Nama Paket
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Paket",
                  hintText: "Contoh: Wedding Photography",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v?.isEmpty ?? true ? "Nama paket harus diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // Deskripsi
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  hintText: "Jelaskan detail paket Anda",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (v) => v?.isEmpty ?? true ? "Deskripsi harus diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // Harga
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Harga",
                  hintText: "Contoh: 1500000",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                  prefixText: "Rp ",
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return "Harga harus diisi";
                  if (double.tryParse(v!) == null) return "Harga harus berupa angka";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Durasi dengan TimePicker
              InkWell(
                onTap: _selectDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Durasi",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDuration,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Termasuk (inclusions)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _inclusionsController,
                    decoration: const InputDecoration(
                      labelText: "Termasuk",
                      hintText: "Foto, Album, Cetak",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.checklist),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pisahkan setiap item dengan koma",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Paket", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}