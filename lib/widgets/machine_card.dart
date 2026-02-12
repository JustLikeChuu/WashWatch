import 'package:flutter/material.dart';
import '../models/machine.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onTap;
  final int queueLength;

  const MachineCard({
    Key? key,
    required this.machine,
    required this.onTap,
    required this.queueLength,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (machine.status) {
      case MachineStatus.available:
        return Colors.green;
      case MachineStatus.inUse:
        return Colors.red;
      case MachineStatus.maintenance:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (machine.status) {
      case MachineStatus.available:
        return 'Available';
      case MachineStatus.inUse:
        return 'In Use';
      case MachineStatus.maintenance:
        return 'Maintenance';
    }
  }

  String _getActionText() {
    switch (machine.status) {
      case MachineStatus.available:
        return 'Use Now';
      case MachineStatus.inUse:
        return 'Join Queue';
      case MachineStatus.maintenance:
        return 'Unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: machine.status == MachineStatus.maintenance ? null : onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStatusColor().withAlpha(255),
                _getStatusColor().withAlpha(179), // 70% opacity
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Machine Name
                Text(
                  machine.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Status & Time
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),
                    if (machine.status == MachineStatus.inUse && machine.timeRemaining != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${machine.timeRemaining} mins left',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    if (queueLength > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '👥 $queueLength in queue',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
                // Action Button
                ElevatedButton(
                  onPressed: machine.status == MachineStatus.maintenance ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _getStatusColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getActionText(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
