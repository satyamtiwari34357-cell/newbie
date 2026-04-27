import "../core/api_endpoints.dart";
import "api_client.dart";

class VendorService {
  Future<Map<String, dynamic>> getVendors() {
    return ApiClient.get(ApiEndpoints.vendors);
  }

  Future<Map<String, dynamic>> getVendorById(String id) {
    return ApiClient.get("${ApiEndpoints.vendors}/$id");
  }

  Future<Map<String, dynamic>> getServices() {
    return ApiClient.get(ApiEndpoints.services);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required double baseCharges,
    required String bio,
  }) {
    return ApiClient.put(
      "${ApiEndpoints.vendors}/profile",
      {"name": name, "baseCharges": baseCharges, "bio": bio},
      token: token,
    );
  }
}
