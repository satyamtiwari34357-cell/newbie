class BookingModel {
  final String id;
  final String date;
  final String time;
  final String status;
  final String paymentStatus;

  BookingModel({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.paymentStatus,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json["_id"] ?? "",
      date: json["date"] ?? "",
      time: json["time"] ?? "",
      status: json["status"] ?? "requested",
      paymentStatus: json["paymentStatus"] ?? "pending",
    );
  }

  BookingModel copyWith({
    String? status,
    String? paymentStatus,
  }) {
    return BookingModel(
      id: id,
      date: date,
      time: time,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
