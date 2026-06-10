// lib/pages/vendor/vendor_orders_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/booking_model.dart';

class VendorOrdersPage extends StatefulWidget {
  const VendorOrdersPage({super.key});

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    
    if (auth.appUser != null) {
      await vendorProvider.loadVendorBookings(auth.appUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);
    final bookings = vendorProvider.vendorBookings;

    if (vendorProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("Belum ada pesanan", style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text("Customer akan muncul di sini setelah booking", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
        await vendorProvider.loadVendorBookings(auth.appUser!.id);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking #${booking.id}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        booking.customerName,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.bookingStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.bookingStatusLabel,
                    style: TextStyle(
                      color: booking.bookingStatusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("${booking.bookingDate} • ${booking.bookingTime}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.serviceTypeLabel,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.paymentStatusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.paymentStatusLabel,
                    style: TextStyle(
                      color: booking.paymentStatusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.totalPrice.toStringAsFixed(0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                if (booking.bookingStatus == 'pending')
                  ElevatedButton(
                    onPressed: () => _showStatusDialog(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Proses Pesanan"),
                  ),
                if (booking.bookingStatus != 'pending')
                  TextButton(
                    onPressed: () => _showBookingDetail(booking),
                    child: const Text("Lihat Detail"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Status Pesanan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.blue),
              title: const Text("Konfirmasi Pesanan"),
              onTap: () => _updateStatus(booking.id, 'confirmed'),
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty, color: Colors.orange),
              title: const Text("Sedang Berlangsung"),
              onTap: () => _updateStatus(booking.id, 'in_progress'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Selesai"),
              onTap: () => _updateStatus(booking.id, 'completed'),
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text("Batalkan"),
              onTap: () => _updateStatus(booking.id, 'cancelled'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final success = await vendorProvider.updateBookingStatus(bookingId, status);
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Status pesanan diperbarui")),
      );
      // Refresh data
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await vendorProvider.loadVendorBookings(auth.appUser!.id);
      setState(() {});
    }
  }

  void _showBookingDetail(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detail Booking #${booking.id}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Customer", booking.customerName),
              _buildDetailRow("No. HP", booking.customerPhone),
              const Divider(),
              _buildDetailRow("Layanan", booking.serviceTypeLabel),
              _buildDetailRow("Tanggal", booking.bookingDate),
              _buildDetailRow("Waktu", booking.bookingTime),
              _buildDetailRow("Lokasi", booking.location),
              const Divider(),
              if (booking.customerNote != null && booking.customerNote!.isNotEmpty)
                _buildDetailRow("Catatan", booking.customerNote!),
              _buildDetailRow("Total Harga", "Rp ${booking.totalPrice.toStringAsFixed(0)}"),
              _buildDetailRow("Status Pesanan", booking.bookingStatusLabel),
              _buildDetailRow("Status Pembayaran", booking.paymentStatusLabel),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}