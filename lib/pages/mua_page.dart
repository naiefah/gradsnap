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

        title: const Text(
          "MUA Indramayu",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            // ================= SEARCH =================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Container(

                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),

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

            // ================= MUA TERDEKAT =================

            buildSectionTitle(
              "MUA Terdekat",
            ),

            const SizedBox(height: 15),

            SizedBox(

              height: 220,

              child: ListView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                scrollDirection: Axis.horizontal,

                children: const [

                  MuaCard(
                    name: "Glow Beauty",
                    location: "Sindang",
                    price: "Rp 350K",
                  ),

                  MuaCard(
                    name: "Cantika Makeup",
                    location: "Indramayu",
                    price: "Rp 400K",
                  ),

                  MuaCard(
                    name: "Beauty Wisuda",
                    location: "Jatibarang",
                    price: "Rp 500K",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= MUA TERMURAH =================

            buildSectionTitle(
              "MUA Termurah",
            ),

            const SizedBox(height: 15),

            SizedBox(

              height: 220,

              child: ListView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                scrollDirection: Axis.horizontal,

                children: const [

                  MuaCard(
                    name: "Simple Makeup",
                    location: "Indramayu",
                    price: "Rp 200K",
                  ),

                  MuaCard(
                    name: "Daily Beauty",
                    location: "Jatibarang",
                    price: "Rp 250K",
                  ),

                  MuaCard(
                    name: "Soft Glam",
                    location: "Sindang",
                    price: "Rp 300K",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= MUA + HAIRDO =================

            buildSectionTitle(
              "MUA + Hair Do",
            ),

            const SizedBox(height: 15),

            SizedBox(

              height: 220,

              child: ListView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                scrollDirection: Axis.horizontal,

                children: const [

                  MuaCard(
                    name: "Queen Makeup",
                    location: "Haurgeulis",
                    price: "Rp 700K",
                  ),

                  MuaCard(
                    name: "Shine Beauty",
                    location: "Lohbener",
                    price: "Rp 650K",
                  ),

                  MuaCard(
                    name: "Elegance MUA",
                    location: "Karangampel",
                    price: "Rp 800K",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= MUA YEARBOOK =================

            buildSectionTitle(
              "MUA Yearbook",
            ),

            const SizedBox(height: 15),

            SizedBox(

              height: 220,

              child: ListView(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                scrollDirection: Axis.horizontal,

                children: const [

                  MuaCard(
                    name: "Glow Art",
                    location: "Indramayu",
                    price: "Rp 450K",
                  ),

                  MuaCard(
                    name: "Studio Beauty",
                    location: "Jatibarang",
                    price: "Rp 500K",
                  ),

                  MuaCard(
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

  Widget buildSectionTitle(
    String title,
  ) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

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