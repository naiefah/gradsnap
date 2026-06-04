import 'package:flutter/material.dart';
import 'package:grad_snap/main.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';



class BookingDetailPage extends StatefulWidget {
  final Map? mapData;

  const BookingDetailPage({super.key, this.mapData});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final Logger logger = Logger();

  Future<bool> _hapusBooking(String idBooking) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.163.72/api_booking/delete.php'),
        body: {
          "id_booking": idBooking,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      logger.e("Error delete booking: $e");
      return false;
    }
  }

  void _dialogHapus() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Booking"),
          content: const Text("Yakin ingin menghapus booking ini?"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                _hapusBooking(widget.mapData!['id_booking']).then((value) {
                  if (value) {
                    navigatorKey.currentState!.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const BookingDetailPage(),
                      ),
                      (route) => false,
                    );
                  }
                });
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.mapData ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Booking"),
        backgroundColor: const Color.fromARGB(255, 250, 237, 202),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nama: ${data['nama'] ?? '-'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tanggal: ${data['tanggal'] ?? '-'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Layanan: ${data['jenis_layanan'] ?? '-'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Harga: ${data['harga'] ?? '-'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _dialogHapus,
                      icon: const Icon(Icons.delete),
                      label: const Text("Hapus"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        navigatorKey.currentState!.pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Kembali"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}