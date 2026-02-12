import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  Booking? _activeBooking;

  Booking? get activeBooking => _activeBooking;

  bool get hasActiveBooking => _activeBooking != null && _activeBooking!.status == BookingStatus.active;

  void setActiveBooking(Booking booking) {
    _activeBooking = booking;
    notifyListeners();
  }

  void completeBooking() {
    if (_activeBooking != null) {
      _activeBooking!.status = BookingStatus.completed;
      notifyListeners();
    }
  }

  void clearBooking() {
    _activeBooking = null;
    notifyListeners();
  }

  int? get timeRemaining => _activeBooking?.timeRemaining;
}
