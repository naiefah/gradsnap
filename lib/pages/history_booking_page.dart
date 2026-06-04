import 'package:flutter/material.dart';
import 'package:grad_snap/main.dart';
import 'booking_detail_page.dart';


class HistoryBookingPage extends StatelessWidget {

  const HistoryBookingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(

        backgroundColor: const Color(0xFFD4AF37),

        elevation: 0,

        title: const Text(

          "Riwayat Booking",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            buildBookingCard(
              title: "Glow Beauty",
              category: "MUA Wisuda",
              date: "12 Mei 2026",
              status: "Pending",
              statusColor: Colors.orange,
              icon: Icons.face_retouching_natural,
            ),

            buildBookingCard(
              title: "Snap Studio",
              category: "Photographer",
              date: "20 Mei 2026",
              status: "Selesai",
              statusColor: Colors.green,
              icon: Icons.camera_alt,
            ),

            buildBookingCard(
              title: "Cantika Makeup",
              category: "MUA + Hair Do",
              date: "25 Mei 2026",
              status: "Diproses",
              statusColor: Colors.blue,
              icon: Icons.face,
            ),

            buildBookingCard(
              title: "Classy Moment",
              category: "Yearbook Session",
              date: "30 Mei 2026",
              status: "Dibatalkan",
              statusColor: Colors.red,
              icon: Icons.photo_camera,
            ),

          ],
        ),
      ),
    );
  }

  Widget buildBookingCard({

    required String title,
    required String category,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,

  }) {

    return Container(

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),

        ],
      ),

      child: Column(

        children: [

          Row(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ICON
              Container(

                width: 65,
                height: 65,

                decoration: BoxDecoration(

                  color: const Color(0xFFD4AF37)
                      .withOpacity(0.12),

                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFFD4AF37),
                  size: 32,
                ),
              ),

              const SizedBox(width: 15),

              // CONTENT
              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      title,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(

                      category,

                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(

                      children: [

                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: Colors.grey[600],
                        ),

                        const SizedBox(width: 5),

                        Text(

                          date,

                          style: TextStyle(
                            color: const Color.fromARGB(255, 97, 97, 97),
                            fontSize: 13,
                          ),
                        ),

                      ],
                    ),

                  ],
                ),
              ),

            ],
          ),

          const SizedBox(height: 18),

          // STATUS + BUTTON
          Row(

            children: [

              Container(

                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                decoration: BoxDecoration(

                  color: statusColor.withOpacity(0.12),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: Text(

                  status,

                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(

                height: 42,

                child: ElevatedButton(
                  onPressed: () {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => BookingDetailPage(
                          mapData: {
                            "nama": title,
                            "tanggal": date,
                            "jenis_layanan": category,
                            "harga": "-",
                          },
                        ),
                      ),
                    );
                  },

                  child: const Text(

                    "Lihat Detail",

                    style: TextStyle(
                      color: Color.fromARGB(255, 227, 118, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}