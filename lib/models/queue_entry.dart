class QueueEntry {
  final String id;
  final String userId;
  final String machineId;
  final DateTime joinedAt;
  DateTime? notifiedAt; // When user was notified they're next
  DateTime? expiresAt; // When the 5 minute window expires

  QueueEntry({
    required this.id,
    required this.userId,
    required this.machineId,
    required this.joinedAt,
    this.notifiedAt,
    this.expiresAt,
  });

  int get position => 0; // Will be calculated by QueueProvider

  int? get timeRemainingInWindow {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  bool get hasExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  String toString() => 'QueueEntry(id: $id, userId: $userId, machineId: $machineId)';
}
