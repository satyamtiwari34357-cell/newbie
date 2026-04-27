import "package:flutter/material.dart";

class BookingSuccessScreen extends StatelessWidget {
  final String date;
  final String time;

  const BookingSuccessScreen({
    super.key,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Animation Placeholder (Using Icons for now)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Booking Successful!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Your service has been scheduled for\n$date at $time",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // Booking Info Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today_outlined, "Scheduled for", "$date, $time"),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.notifications_active_outlined, "Notifications", "Sent to Vendor & You"),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Actions
              FilledButton(
                onPressed: () {
                  // Navigate back to home (resets navigation stack)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                   Navigator.of(context).popUntil((route) => route.isFirst);
                   // In a real app, this would switch to the "My Bookings" tab
                },
                child: const Text("Track Booking Status"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
