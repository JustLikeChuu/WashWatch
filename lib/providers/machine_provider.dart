import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine.dart';

class MachineProvider extends ChangeNotifier {
  final List<Machine> _machines = [];
  late Timer _timer;

  List<Machine> get machines => _machines;

  MachineProvider() {
    _initializeMachines();
    _startTimer();
  }

  void _initializeMachines() {
    _machines.addAll([
      Machine(id: 'M001', name: 'Washer 1'),
      Machine(id: 'M002', name: 'Washer 2'),
      Machine(id: 'M003', name: 'Washer 3'),
      Machine(id: 'M004', name: 'Washer 4'),
      Machine(id: 'M005', name: 'Washer 5'),
      Machine(id: 'M006', name: 'Washer 6'),
    ]);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateMachines();
    });
  }

  void _updateMachines() {
    // Check if any machines' inUseUntil has passed
    for (var machine in _machines) {
      if (machine.status == MachineStatus.inUse && machine.inUseUntil != null) {
        if (DateTime.now().isAfter(machine.inUseUntil!)) {
          machine.status = MachineStatus.available;
          machine.currentUserId = null;
          machine.inUseUntil = null;
        }
      }
    }
    notifyListeners();
  }

  Machine? getMachine(String machineId) {
    try {
      return _machines.firstWhere((m) => m.id == machineId);
    } catch (e) {
      return null;
    }
  }

  void setMachineInUse(String machineId, String userId, Duration duration) {
    final machine = getMachine(machineId);
    if (machine != null) {
      machine.status = MachineStatus.inUse;
      machine.currentUserId = userId;
      machine.inUseUntil = DateTime.now().add(duration);
      notifyListeners();
    }
  }

  void setMachineFree(String machineId) {
    final machine = getMachine(machineId);
    if (machine != null) {
      machine.status = MachineStatus.available;
      machine.currentUserId = null;
      machine.inUseUntil = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
