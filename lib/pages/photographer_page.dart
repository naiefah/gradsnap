// photographer_page.dart
import 'package:flutter/material.dart';
import 'package:grad_snap/models/service_package.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/service_package_card.dart';
import '../pages/detail_service_page.dart';

class PhotographerPage extends StatefulWidget {
  const PhotographerPage({super.key});

  @override
  State<PhotographerPage> createState() => _PhotographerPageState();
}

class _PhotographerPageState extends State<PhotographerPage> {
  @override
  void initState() {
    super.initState();
    // Load data setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
      vendorProvider.loadAllPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    
    // Ambil hanya package Photographer
    final photographerPackages = vendorProvider.photographerPackages;
    
    // Kelompokkan berdasarkan kategori
    final semuaPhotographer = photographerPackages;
    final terdekat = photographerPackages.take(3).toList();
    final termurah = [...photographerPackages]..sort((a, b) => a.price.compareTo(b.price));
    final yearbook = photographerPackages.where((p) => p.name.contains('Yearbook')).toList();
    final prewedding = photographerPackages.where((p) => p.name.contains('Prewedding')).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Photographer Indramayu",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: vendorProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data Photographer...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 30),
                  
                  if (semuaPhotographer.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada Photographer yang tersedia',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Photographer Terdekat
                    if (terdekat.isNotEmpty) ...[
                      _buildSectionTitle("Photographer Terdekat"),
                      const SizedBox(height: 15),
                      _buildHorizontalList(terdekat),
                      const SizedBox(height: 25),
                    ],
                    
                    // Photographer Termurah
                    if (termurah.isNotEmpty) ...[
                      _buildSectionTitle("Photographer Termurah"),
                      const SizedBox(height: 15),
                      _buildHorizontalList(termurah.take(6).toList()),
                      const SizedBox(height: 25),
                    ],
                    
                    // Photographer Yearbook
                    if (yearbook.isNotEmpty) ...[
                      _buildSectionTitle("Photographer Yearbook"),
                      const SizedBox(height: 15),
                      _buildHorizontalList(yearbook),
                      const SizedBox(height: 25),
                    ],
                    
                    // Photographer Prewedding
                    if (prewedding.isNotEmpty) ...[
                      _buildSectionTitle("Prewedding Style"),
                      const SizedBox(height: 15),
                      _buildHorizontalList(prewedding),
                      const SizedBox(height: 25),
                    ],
                    
                    // Semua Photographer
                    _buildSectionTitle("Semua Photographer"),
                    const SizedBox(height: 15),
                    _buildGridList(semuaPhotographer),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.search),
            hintText: "Cari Photographer...",
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<ServicePackage> packages) {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: packages.map((package) {
          return ServicePackageCard(
            package: package,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailServicePage(package: package),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridList(List<ServicePackage> packages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.7,
        ),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          return ServicePackageCard(
            package: packages[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailServicePage(package: packages[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            "See All",
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}