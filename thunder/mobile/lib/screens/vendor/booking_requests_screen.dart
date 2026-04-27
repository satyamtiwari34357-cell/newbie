import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:intl/intl.dart";

import "../../providers/auth_provider.dart";
import "../../providers/booking_provider.dart";

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<BookingProvider>().fetchBookings(token);
      }
    });
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final success = await context.read<BookingProvider>().updateBookingStatus(
      token: token,
      bookingId: bookingId,
      status: status,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? "Booking $status!" : "Failed to update status")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final bookings = provider.bookings.where((b) => b.status == "requested").toList();
    final theme = Theme.of(context);

    if (provider.loading && bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No pending requests", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Booking #${booking.id.substring(booking.id.length - 6)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Text("NEW", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text("Service Requested", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(booking.date, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(booking.time, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(booking.id, "rejected"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _updateStatus(booking.id, "accepted"),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Accept"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
