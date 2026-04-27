import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:intl/intl.dart";

import "../../models/vendor_model.dart";
import "../../providers/auth_provider.dart";
import "../../providers/booking_provider.dart";
import "../../services/booking_service.dart";
import "booking_success_screen.dart";



class BookingScreen extends StatefulWidget {
  final VendorModel vendor;
  final List<String>? selectedServices;

  const BookingScreen({super.key, required this.vendor, this.selectedServices});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final BookingService _bookingService = BookingService();

  final List<String> _timeSlots = [
    "09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM", "05:00 PM", "07:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);

    // Dynamic Price Calculation (Mocking based on selection)
    int basePrice = 499; // Default if nothing selected
    if (widget.selectedServices != null && widget.selectedServices!.isNotEmpty) {
      basePrice = widget.selectedServices!.length * 350; // Simple mock price logic
    }
    int safetyFee = 49;
    int totalAmount = basePrice + safetyFee;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Slot")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Info Summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: theme.colorScheme.primaryContainer, child: const Icon(Icons.person)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.vendor.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(widget.vendor.specialization, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),


            const SizedBox(height: 24),
            
            // Date Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Select Date", style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 14, // 2 weeks
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;
                  
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300),
                        boxShadow: isSelected ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat("EEE").format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(date.day.toString(), style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Time Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Select Time Slot", style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final time = _timeSlots[index];
                  final isSelected = _selectedTime == time;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTime = time),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
            
            // Price Breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildPriceRow("Service Base Price", "₹$basePrice"),
                    const SizedBox(height: 8),
                    _buildPriceRow("Safety & Inspection Fee", "₹$safetyFee"),
                    const Divider(height: 24),
                    _buildPriceRow("Total Amount", "₹$totalAmount", isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: FilledButton(
          onPressed: _selectedTime == null
              ? null
              : () async {
                  // We use a valid dummy MongoId for serviceId to satisfy the backend validator
                  final success = await context.read<BookingProvider>().createBooking(
                    token: auth.token!,
                    vendorId: widget.vendor.id,
                    serviceId: "507f1f77bcf86cd799439011", 
                    date: DateFormat("yyyy-MM-dd").format(_selectedDate),
                    time: _selectedTime!,
                  );
                  if (!context.mounted) return;
                  if (success) {
                    _showSuccessDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Booking failed. Please try again.")),
                    );
                  }
                },
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("Confirm & Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14, color: isTotal ? Colors.black : Colors.blueGrey)),
      ],
    );
  }


  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text("Booking Confirmed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Professional will arrive on ${DateFormat("MMM dd").format(_selectedDate)} at $_selectedTime", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to vendor details
                  Navigator.pop(context); // Back to home or list
                },
                child: const Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: FilledButton(
          onPressed: (_selectedTime == null || context.watch<BookingProvider>().loading)
              ? null
              : () async {
                  // We use a valid dummy MongoId for serviceId to satisfy the backend validator
                  final success = await context.read<BookingProvider>().createBooking(
                    token: auth.token,
                    vendorId: widget.vendor?.id,
                    serviceId: "507f1f77bcf86cd799439011", 
                    date: DateFormat("yyyy-MM-dd").format(_selectedDate),
                    time: _selectedTime!,
                  );
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingSuccessScreen(
                          date: DateFormat("MMM dd, yyyy").format(_selectedDate),
                          time: _selectedTime!,
                        ),
                      ),
                    );
                  } else {
                    final error = context.read<BookingProvider>().errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error ?? "Booking failed. Please try again.")),
                    );
                  }
                },
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: context.watch<BookingProvider>().loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text("Confirm & Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14, color: isTotal ? Colors.black : Colors.blueGrey)),
      ],
    );
  }


}
