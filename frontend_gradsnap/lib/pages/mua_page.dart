import 'package:flutter/material.dart';
import '../widgets/mua_card.dart';

class MuaPage extends StatelessWidget {
  const MuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "MUA Indramayu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // SEARCH
            Padding(
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
                    hintText: "Cari MUA...",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // MUA TERDEKAT
            buildSectionTitle("MUA Terdekat"),
            const SizedBox(height: 15),

            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  MuaCard(
                    id: 1,
                    name: "Glow Beauty",
                    location: "Sindang",
                    price: "Rp 350K",
                  ),
                  MuaCard(
                    id: 2,
                    name: "Cantika Makeup",
                    location: "Indramayu",
                    price: "Rp 400K",
                  ),
                  MuaCard(
                    id: 3,
                    name: "Beauty Wisuda",
                    location: "Jatibarang",
                    price: "Rp 500K",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // MUA TERMURAH
            buildSectionTitle("MUA Termurah"),
            const SizedBox(height: 15),

            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  MuaCard(
                    id: 4,
                    name: "Simple Makeup",
                    location: "Indramayu",
                    price: "Rp 200K",
                  ),
                  MuaCard(
                    id: 5,
                    name: "Daily Beauty",
                    location: "Jatibarang",
                    price: "Rp 250K",
                  ),
                  MuaCard(
                    id: 6,
                    name: "Soft Glam",
                    location: "Sindang",
                    price: "Rp 300K",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // MUA + HAIR DO
            buildSectionTitle("MUA + Hair Do"),
            const SizedBox(height: 15),

            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  MuaCard(
                    id: 7,
                    name: "Queen Makeup",
                    location: "Haurgeulis",
                    price: "Rp 700K",
                  ),
                  MuaCard(
                    id: 8,
                    name: "Shine Beauty",
                    location: "Lohbener",
                    price: "Rp 650K",
                  ),
                  MuaCard(
                    id: 9,
                    name: "Elegance MUA",
                    location: "Karangampel",
                    price: "Rp 800K",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // MUA YEARBOOK
            buildSectionTitle("MUA Yearbook"),
            const SizedBox(height: 15),

            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  MuaCard(
                    id: 10,
                    name: "Glow Art",
                    location: "Indramayu",
                    price: "Rp 450K",
                  ),
                  MuaCard(
                    id: 11,
                    name: "Studio Beauty",
                    location: "Jatibarang",
                    price: "Rp 500K",
                  ),
                  MuaCard(
                    id: 12,
                    name: "Classy Makeup",
                    location: "Sindang",
                    price: "Rp 550K",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "See All",
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}