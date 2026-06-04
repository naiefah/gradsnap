import 'package:flutter/material.dart';

import '../widgets/photographer_card.dart';

class PhotographerPage extends StatelessWidget {
  const PhotographerPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(

        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,

        title: const Text(
          "Photographer Indramayu",
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
                    hintText: "Cari Photographer...",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= TERDEKAT =================

            buildSectionTitle(
              "Photographer Terdekat",
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

                  PhotographerCard(
                    name: "Snap Studio",
                    location: "Sindang",
                    price: "Rp 500K",
                  ),

                  PhotographerCard(
                    name: "Wisuda Shot",
                    location: "Indramayu",
                    price: "Rp 450K",
                  ),

                  PhotographerCard(
                    name: "Classy Moment",
                    location: "Jatibarang",
                    price: "Rp 600K",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= TERMURAH =================

            buildSectionTitle(
              "Photographer Termurah",
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

                  PhotographerCard(
                    name: "Simple Shoot",
                    location: "Indramayu",
                    price: "Rp 250K",
                  ),

                  PhotographerCard(
                    name: "Daily Photo",
                    location: "Sindang",
                    price: "Rp 300K",
                  ),

                  PhotographerCard(
                    name: "Best Capture",
                    location: "Lohbener",
                    price: "Rp 350K",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= YEARBOOK =================

            buildSectionTitle(
              "Photographer Yearbook",
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

                  PhotographerCard(
                    name: "Yearbook Studio",
                    location: "Karangampel",
                    price: "Rp 750K",
                  ),

                  PhotographerCard(
                    name: "Memory Capture",
                    location: "Jatibarang",
                    price: "Rp 700K",
                  ),

                  PhotographerCard(
                    name: "Golden Shoot",
                    location: "Indramayu",
                    price: "Rp 850K",
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= PREWEDDING STYLE =================

            buildSectionTitle(
              "Prewedding Style",
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

                  PhotographerCard(
                    name: "Elegant Shot",
                    location: "Haurgeulis",
                    price: "Rp 950K",
                  ),

                  PhotographerCard(
                    name: "Cinematic Photo",
                    location: "Sindang",
                    price: "Rp 1.2JT",
                  ),

                  PhotographerCard(
                    name: "Luxury Moment",
                    location: "Indramayu",
                    price: "Rp 1JT",
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