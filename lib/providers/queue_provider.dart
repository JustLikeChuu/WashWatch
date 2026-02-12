import 'dart:async';
import 'package:flutter/material.dart';
import '../models/queue_entry.dart';
import '../services/queue_service.dart';

class QueueProvider extends ChangeNotifier {
  final QueueService queueService = QueueService();
  late Timer _updateTimer;

  QueueProvider() {
    _initializeQueues();
    _startUpdateTimer();
  }

  void _initializeQueues() {
    final machineIds = ['M001', 'M002', 'M003', 'M004', 'M005', 'M006'];
    for (var id in machineIds) {
      queueService.initializeMachine(id);
    }
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Check for expired entries
      for (var machineId in ['M001', 'M002', 'M003', 'M004', 'M005', 'M006']) {
        final queue = queueService.getQueue(machineId);
        queue.removeWhere((entry) => entry.hasExpired);
      }
      notifyListeners();
    });
  }

  void addToQueue(String userId, String machineId) {
    queueService.addToQueue(userId, machineId);
    notifyListeners();
  }

  void removeFromQueue(String userId, String machineId) {
    queueService.removeFromQueue(userId, machineId);
    notifyListeners();
  }

  List<QueueEntry> getQueueForMachine(String machineId) {
    return queueService.getQueue(machineId);
  }

  int? getUserQueuePosition(String userId, String machineId) {
    final position = queueService.getQueuePosition(userId, machineId);
    return position;
  }

  QueueEntry? getNextInQueue(String machineId) {
    return queueService.getNextInQueue(machineId);
  }

  void markUserAsNotified(String userId, String machineId) {
    queueService.markAsNotified(userId, machineId);
    notifyListeners();
  }

  int getQueueLength(String machineId) {
    return queueService.getQueueLength(machineId);
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }
}
