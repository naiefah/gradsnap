import 'package:flutter/material.dart';

import 'booking_page.dart';

class DetailMuaPage extends StatelessWidget {
  const DetailMuaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Stack(
              children: [

                Container(
                  height: 320,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                  ),

                  child: const Center(
                    child: Icon(
                      Icons.face_retouching_natural,
                      size: 120,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        CircleAvatar(
                          backgroundColor: Colors.white,

                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        CircleAvatar(
                          backgroundColor: Colors.white,

                          child: IconButton(
                            onPressed: () {},

                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),

            // ================= CONTENT =================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // NAME
                  const Text(
                    "Glow Beauty",

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // LOCATION + RATING
                  Row(
                    children: [

                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[700],
                      ),

                      const SizedBox(width: 5),

                      Text(
                        "Indramayu",

                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      const Text(
                        "4.9",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 25),

                  // ABOUT
                  const Text(
                    "Tentang",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "MUA profesional untuk wisuda, yearbook, prewedding, dan berbagai event spesial dengan hasil makeup elegan, flawless, dan tahan lama.",

                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SERVICES
                  const Text(
                    "Layanan",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,

                    children: [

                      buildService("Makeup Wisuda"),
                      buildService("Hair Do"),
                      buildService("Yearbook"),
                      buildService("Prewedding"),
                      buildService("Softlens"),

                    ],
                  ),

                  const SizedBox(height: 30),

                  // PRICE
                  const Text(
                    "Harga Mulai",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Rp 350K",

                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // BUTTONS
                  Row(
                    children: [

                      Expanded(
                        child: SizedBox(
                          height: 55,

                          child: OutlinedButton(
                            onPressed: () {},

                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFD4AF37),
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),

                            child: const Text(
                              "Chat",

                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        flex: 2,

                        child: SizedBox(
                          height: 55,

                          child: ElevatedButton(

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (context) =>
                                      const BookingPage(
                                    name: "Glow Beauty",
                                    price: "Rp 350K",
                                  ),

                                ),

                              );

                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFD4AF37),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),

                            child: const Text(
                              "Booking Sekarang",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildService(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}