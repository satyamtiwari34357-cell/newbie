import "../core/api_endpoints.dart";
import "api_client.dart";

class BookingService {
  Future<Map<String, dynamic>> getBookings(String token) {
    return ApiClient.get(ApiEndpoints.bookings, token: token);
  }

  Future<Map<String, dynamic>> createBooking({
    String? token,
    String? vendorId,
    required String serviceId,
    required String date,
    required String time,
  }) {
    return ApiClient.post(
      ApiEndpoints.bookings,
      {
        if (vendorId != null) "vendorId": vendorId,
        "serviceId": serviceId,
        "date": date,
        "time": time,
      },
      token: token,
    );
  }

  Future<Map<String, dynamic>> updateStatus(String token, String bookingId, String status) {
    return ApiClient.put("${ApiEndpoints.bookings}/$bookingId/status", {"status": status}, token: token);
  }
}
