import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  String _currentAddress = "Loading location...";
  Position? _currentPosition;

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;

  /// Fetches the user's current location and updates the address.
  Future<void> fetchLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        _currentAddress = await LocationService.getAddressFromLatLng(position);
        notifyListeners();
      }
    } catch (e) {
      _currentAddress = "Location access denied";
      notifyListeners();
    }
  }

  void updateAddress(String newAddress) {
    _currentAddress = newAddress;
    notifyListeners();
  }
}
