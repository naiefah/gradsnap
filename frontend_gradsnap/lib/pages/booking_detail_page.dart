  // pages/booking_detail_page.dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/booking_provider.dart';
  import '../models/booking_model.dart';

  class BookingDetailPage extends StatefulWidget {
    final Map<String, dynamic>? mapData;
    final BookingModel? booking;

    const BookingDetailPage({
      super.key,
      this.mapData,
      this.booking,
    });

    @override
    State<BookingDetailPage> createState() => _BookingDetailPageState();
  }

  class _BookingDetailPageState extends State<BookingDetailPage> {
    bool _isLoading = false;
    late BookingModel _booking;

    @override
    void initState() {
      super.initState();
      // Initialize booking dari mapData atau booking model
      if (widget.booking != null) {
        _booking = widget.booking!;
      } else if (widget.mapData != null) {
        _booking = BookingModel.fromJson(widget.mapData!);
      } else {
        _booking = BookingModel(
          id: 0,
          customerName: '',
          customerPhone: '',
          serviceName: '',
          serviceType: '',
          bookingDate: '',
          bookingTime: '',
          location: '',
          additionalRequest: '',
          customerNote: null,
          totalPrice: 0,
          paymentStatus: 'pending',
          bookingStatus: 'pending',
          createdAt: DateTime.now(),
          updatedAt: null,
        );
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
                  Navigator.of(context).pop();
                  setState(() => _isLoading = true);
                  
                  final provider = Provider.of<BookingProvider>(context, listen: false);
                  final success = await provider.deleteBooking(_booking.id);
                  
                  setState(() => _isLoading = false);
                  
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking berhasil dihapus"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true);
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

    void _dialogUpdateStatus() {
      final List<String> statusList = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Update Status"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: statusList.map((status) {
                return ListTile(
                  title: Text(_getStatusLabel(status)),
                  leading: Radio<String>(
                    value: status,
                    groupValue: _booking.bookingStatus,
                    onChanged: (value) async {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      
                      final provider = Provider.of<BookingProvider>(context, listen: false);
                      final success = await provider.updateBookingStatus(_booking.id, value!);
                      
                      if (success) {
                        setState(() {
                          _booking = BookingModel.fromJson({
                            ..._booking.toJson(),
                            'booking_status': value,
                          });
                          _isLoading = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Status berhasil diupdate"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        setState(() => _isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal update status"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }

    String _getStatusLabel(String status) {
      switch (status) {
        case 'pending': return 'Menunggu Konfirmasi';
        case 'confirmed': return 'Dikonfirmasi';
        case 'in_progress': return 'Sedang Berlangsung';
        case 'completed': return 'Selesai';
        case 'cancelled': return 'Dibatalkan';
        default: return status;
      }
    }

    String _getPaymentStatusLabel(String status) {
      switch (status) {
        case 'pending': return 'Menunggu Pembayaran';
        case 'paid': return 'Sudah Dibayar';
        case 'failed': return 'Pembayaran Gagal';
        case 'refunded': return 'Dikembalikan';
        default: return status;
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Detail Booking"),
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
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
                        _buildDetailRow("ID Booking", _booking.id.toString()),
                        const Divider(),
                        _buildDetailRow("Nama", _booking.customerName),
                        const Divider(),
                        _buildDetailRow("No. WhatsApp", _booking.customerPhone),
                        const Divider(),
                        _buildDetailRow("Tanggal", _booking.bookingDate),
                        const Divider(),
                        _buildDetailRow("Jam", _booking.bookingTime),
                        const Divider(),
                        _buildDetailRow("Lokasi", _booking.location),
                        const Divider(),
                        _buildDetailRow("Layanan", _booking.serviceName),
                        const Divider(),
                        _buildDetailRow("Tipe Layanan", _booking.serviceTypeLabel),
                        const Divider(),
                        _buildDetailRow("Harga", "Rp ${_booking.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"),
                        const Divider(),
                        _buildStatusRow("Status Booking", _booking.bookingStatusLabel, _booking.bookingStatusColor),
                        const Divider(),
                        _buildStatusRow("Status Pembayaran", _getPaymentStatusLabel(_booking.paymentStatus), _booking.paymentStatus == 'paid' ? Colors.green : Colors.orange),
                        if (_booking.additionalRequest.isNotEmpty) ...[
                          const Divider(),
                          _buildDetailRow("Permintaan Khusus", _booking.additionalRequest, isLongText: true),
                        ],
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_booking.bookingStatus != 'completed' && _booking.bookingStatus != 'cancelled')
                              ElevatedButton.icon(
                                onPressed: _dialogUpdateStatus,
                                icon: const Icon(Icons.update),
                                label: const Text("Update Status"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
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

    Widget _buildDetailRow(String label, String value, {bool isLongText = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
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
                style: TextStyle(fontSize: 16, height: isLongText ? 1.5 : 1),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildStatusRow(String label, String value, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }