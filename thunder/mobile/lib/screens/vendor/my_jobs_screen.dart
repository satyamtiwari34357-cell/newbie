import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../providers/auth_provider.dart";
import "../../providers/booking_provider.dart";

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final bookings = provider.bookings;
    final theme = Theme.of(context);

    if (provider.loading && bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("No upcoming jobs yet", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final isBroadcast = booking.status == "requested"; // In our logic, requested but visible means broadcast or specific request

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              "Service Booking #${booking.id.substring(booking.id.length - 6)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(booking.date),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(booking.time),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (booking.status == "accepted" ? Colors.green : Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: booking.status == "accepted" ? Colors.green : Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: isBroadcast
                ? FilledButton(
                    onPressed: () async {
                      final token = context.read<AuthProvider>().token;
                      if (token == null) return;
                      await context.read<BookingProvider>().updateBookingStatus(
                        token: token,
                        bookingId: booking.id,
                        status: "accepted",
                      );
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Accept Job"),
                  )
                : (booking.status == "accepted"
                    ? FilledButton(
                        onPressed: () {},
                        child: const Text("Mark Done"),
                      )
                    : null),
          ),
        );
      },
    );
  }
}
