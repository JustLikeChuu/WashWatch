import 'package:uuid/uuid.dart';
import '../models/queue_entry.dart';

class QueueService {
  static const Duration queueTimeoutWindow = Duration(seconds: 10); // 10 seconds for demo, easier to see queue progression

  final Map<String, List<QueueEntry>> _queues = {};

  void initializeMachine(String machineId) {
    _queues[machineId] = [];
  }

  void addToQueue(String userId, String machineId) {
    _queues.putIfAbsent(machineId, () => []);
    final entry = QueueEntry(
      id: const Uuid().v4(),
      userId: userId,
      machineId: machineId,
      joinedAt: DateTime.now(),
    );
    _queues[machineId]!.add(entry);
  }

  void removeFromQueue(String userId, String machineId) {
    _queues[machineId]?.removeWhere((entry) => entry.userId == userId);
  }

  List<QueueEntry> getQueue(String machineId) {
    return _queues[machineId] ?? [];
  }

  int? getQueuePosition(String userId, String machineId) {
    final queue = getQueue(machineId);
    final index = queue.indexWhere((entry) => entry.userId == userId);
    return index >= 0 ? index : null;
  }

  QueueEntry? getNextInQueue(String machineId) {
    final queue = getQueue(machineId);
    if (queue.isEmpty) return null;

    // Check if first entry has expired
    if (queue.first.hasExpired) {
      queue.removeAt(0);
      return queue.isEmpty ? null : queue.first;
    }

    return queue.first;
  }

  void markAsNotified(String userId, String machineId) {
    final queue = getQueue(machineId);
    final entry = queue.firstWhere((e) => e.userId == userId);
    entry.notifiedAt = DateTime.now();
    entry.expiresAt = DateTime.now().add(queueTimeoutWindow);
  }

  int getQueueLength(String machineId) {
    return getQueue(machineId).length;
  }

  void clearQueue(String machineId) {
    _queues[machineId] = [];
  }
}
