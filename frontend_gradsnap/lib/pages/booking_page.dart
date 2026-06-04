import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  final String name;
  final String price;

  const BookingPage({
    super.key,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD4AF37),
        elevation: 0,

        title: const Text(
          "Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // CARD INFO
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),

              child: Row(
                children: [

                  Container(
                    width: 70,
                    height: 70,

                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons.face_retouching_natural,
                      size: 38,
                      color: Color(0xFFD4AF37),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          name,

                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          price,

                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

            // FORM TITLE
            const Text(
              "Isi Data Booking",

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // NAMA
            buildTextField(
              label: "Nama Lengkap",
              hint: "Masukkan nama",
              icon: Icons.person,
            ),

            const SizedBox(height: 18),

            // WA
            buildTextField(
              label: "Nomor WhatsApp",
              hint: "08xxxxxxxxxx",
              icon: Icons.phone,
            ),

            const SizedBox(height: 18),

            // TANGGAL
            buildTextField(
              label: "Tanggal Booking",
              hint: "Pilih tanggal",
              icon: Icons.calendar_month,
            ),

            const SizedBox(height: 18),

            // JAM
            buildTextField(
              label: "Jam Booking",
              hint: "Contoh: 09.00 WIB",
              icon: Icons.access_time,
            ),

            const SizedBox(height: 18),

            // CATATAN
            buildTextField(
              label: "Catatan Tambahan",
              hint: "Tambahkan request makeup/photo",
              icon: Icons.note_alt,
              maxLines: 4,
            ),

            const SizedBox(height: 35),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(
                      content:
                          Text("Booking berhasil dikirim"),
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
                  "Konfirmasi Booking",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          label,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          maxLines: maxLines,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(icon),

            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
        ),

      ],
    );
  }
}