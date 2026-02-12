enum BookingStatus { active, completed, cancelled }

class Booking {
  final String id;
  final String userId;
  final String machineId;
  final DateTime startTime;
  final Duration estimatedDuration;
  BookingStatus status;

  Booking({
    required this.id,
    required this.userId,
    required this.machineId,
    required this.startTime,
    required this.estimatedDuration,
    this.status = BookingStatus.active,
  });

  DateTime get endTime => startTime.add(estimatedDuration);

  int? get timeRemaining {
    final now = DateTime.now();
    final remaining = endTime.difference(now).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  @override
  String toString() => 'Booking(id: $id, userId: $userId, machineId: $machineId, status: $status)';
}
