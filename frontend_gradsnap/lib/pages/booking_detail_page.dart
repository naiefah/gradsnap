import 'package:flutter/material.dart';
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                
                final idBooking = widget.mapData?['id_booking'] ?? '';
                final success = await _hapusBooking(idBooking);
                
                if (success && context.mounted) {
                  // Tampilkan pesan sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Booking berhasil dihapus"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Kembali ke halaman sebelumnya
                  Navigator.pop(context);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal menghapus booking"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
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
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow("ID Booking", data['id_booking'] ?? '-'),
                const Divider(),
                _buildDetailRow("Nama", data['nama'] ?? '-'),
                const Divider(),
                _buildDetailRow("Tanggal", data['tanggal'] ?? '-'),
                const Divider(),
                _buildDetailRow("Layanan", data['jenis_layanan'] ?? '-'),
                const Divider(),
                _buildDetailRow("Harga", data['harga'] ?? '-'),
                const Divider(),
                _buildDetailRow("Status", data['status'] ?? '-'),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _dialogHapus,
                      icon: const Icon(Icons.delete),
                      label: const Text("Hapus Booking"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Kembali"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}