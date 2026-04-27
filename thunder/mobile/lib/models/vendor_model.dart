class VendorModel {
  final String id;
  final String name;
  final String phone;
  final String specialization;
  final double rating;
  final double baseCharges;
  final String bio;

  VendorModel({
    required this.id,
    required this.name,
    required this.phone,
    this.specialization = "Expert Service Provider",
    this.rating = 4.8,
    this.baseCharges = 0,
    this.bio = "",
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    // If the data is coming from the updateProfile endpoint, it might have 'user' and 'profile' keys
    final userData = json.containsKey("user") ? json["user"] : json;
    final profileData = json.containsKey("profile") ? json["profile"] : {};

    return VendorModel(
      id: userData["_id"] ?? "",
      name: userData["name"] ?? "Vendor",
      phone: userData["phone"] ?? "",
      specialization: userData["specialization"] ?? profileData["specialization"] ?? "Expert Service Provider",
      rating: (userData["rating"] ?? profileData["rating"] ?? 4.8).toDouble(),
      baseCharges: (profileData["baseCharges"] ?? 0).toDouble(),
      bio: profileData["bio"] ?? "",
    );
  }
}
