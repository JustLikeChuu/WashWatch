import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../models/queue_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/machine_provider.dart';
import '../providers/queue_provider.dart';
import '../services/notification_service.dart';
import '../widgets/queue_position_card.dart';

class QueuePositionScreen extends StatefulWidget {
  final Machine machine;

  const QueuePositionScreen({
    Key? key,
    required this.machine,
  }) : super(key: key);

  @override
  State<QueuePositionScreen> createState() => _QueuePositionScreenState();
}

class _QueuePositionScreenState extends State<QueuePositionScreen> {
  late Timer _updateTimer;
  bool _queueLeft = false;
  bool _autoStarted = false; // Track if we've already auto-started this person's wash
  String? _lastMachineUser; // Track previous machine user to detect when they finish
  late MachineProvider _machineProvider;
  late QueueProvider _queueProvider;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthProvider>().currentUser;
    _queueProvider = context.read<QueueProvider>();
    _machineProvider = context.read<MachineProvider>();

    // Add user to queue
    _queueProvider.addToQueue(currentUser!.matricId, widget.machine.id);

    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _queueLeft) return;

      final position = _queueProvider.getUserQueuePosition(
        currentUser.matricId,
        widget.machine.id,
      );

      // Get current machine state
      final currentMachine = _machineProvider.getMachine(widget.machine.id);
      final currentMachineUser = currentMachine?.currentUserId;

      // Detect when machine user changes (person ahead finished)
      if (_lastMachineUser != null && _lastMachineUser != currentMachineUser) {
        // If it was ME using the machine and now no one is - FOR DEMO: just show message, don't remove
        if (_lastMachineUser == currentUser.matricId && currentMachineUser == null) {
          // FOR DEMO: Don't remove real user from queue, just show completion message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your wash is complete! Please collect your laundry.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
          // Don't pop or remove - keep them on the screen for demo
        }
        
        // ALSO: If someone else was using the machine and finished, remove them from queue
        // This handles the case where they left the screen before finishing
        if (_lastMachineUser != null && currentMachineUser == null && _lastMachineUser != currentUser.matricId) {
          _queueProvider.removeFromQueue(_lastMachineUser!, widget.machine.id);
          
          // AUTO-START next person in queue (for demo purposes - simulates they're also on a screen)
          final queue = _queueProvider.getQueueForMachine(widget.machine.id);
          if (queue.isNotEmpty) {
            final nextUser = queue.first;
            Future.delayed(const Duration(milliseconds: 500), () {
              _machineProvider.setMachineInUse(
                widget.machine.id,
                nextUser.userId,
                const Duration(seconds: 10),
              );
            });
          }
        }
      }
      _lastMachineUser = currentMachineUser;

      // Check if user is at position 0 in queue - AUTO-START their wash
      if (position == 0 && !_autoStarted) {
        _autoStarted = true;
        _queueProvider.markUserAsNotified(currentUser.matricId, widget.machine.id);
        
        // For DEMO: Check if this is the real user or a demo user
        bool isRealUser = !currentUser.matricId.startsWith('demo_');
        
        if (isRealUser) {
          // REAL USER: Stay at position 0 with 5-minute scanning window visible
          // Don't auto-start, let them manually proceed or let 5 minutes expire
          NotificationService().showYourTurnNotification(widget.machine.name);
          // The QueuePositionCard will show the 5-minute scanning timer
        } else {
          // DEMO USER: Auto-start after 2 seconds
          NotificationService().showYourTurnNotification(widget.machine.name);
          
          // Show in-app notification for demo users only
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("You're next! Automatically starting your wash in 2 seconds..."),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Auto-start demo user after 2 seconds (simulating QR scan + payment)
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !_queueLeft) {
              // REMOVE FROM QUEUE FIRST - this is critical so next person gets position 0
              _queueProvider.removeFromQueue(currentUser.matricId, widget.machine.id);
              
              // Auto-start the wash for 10 seconds
              _machineProvider.setMachineInUse(
                widget.machine.id,
                currentUser.matricId,
                const Duration(seconds: 10),
              );
            }
          });
        }
      }

      // Check if user's queue time window has expired
      final queue = _queueProvider.getQueueForMachine(widget.machine.id);
      final userEntryIndex = queue.indexWhere(
        (entry) => entry.userId == currentUser.matricId,
      );

      if (userEntryIndex >= 0) {
        final userEntry = queue[userEntryIndex];
        if (userEntry.hasExpired && position == 0) {
          _queueLeft = true;
          _queueProvider.removeFromQueue(currentUser.matricId, widget.machine.id);
          NotificationService().showTimeExpiredNotification();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Time expired. You have been moved to the back of the queue.'),
                backgroundColor: Colors.red,
              ),
            );

            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        }
      }

      // Check if user is still in queue OR is currently using the machine
      final isUserUsingMachine = currentMachine?.currentUserId == currentUser.matricId;
      final isUserInQueue = _queueProvider.getUserQueuePosition(currentUser.matricId, widget.machine.id) != null;
      
      // Only exit if they were using machine and it finished (not just if they're not in queue)
      // This prevents premature exit when transitioning from queue to machine use
      if (!isUserInQueue && !isUserUsingMachine && _lastMachineUser == currentUser.matricId && currentMachineUser == null) {
        _queueLeft = true;
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Position'),
        backgroundColor: const Color(0xFF00BCD4),
      ),
      body: Consumer2<QueueProvider, MachineProvider>(
        builder: (context, queueProvider, machineProvider, _) {
          if (_queueLeft) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final position = queueProvider.getUserQueuePosition(
            currentUser!.matricId,
            widget.machine.id,
          );

          // Check if user is currently using the machine (even if not in queue)
          final machine = machineProvider.getMachine(widget.machine.id);
          final isCurrentUser = machine?.currentUserId == currentUser.matricId;

          if (position == null && !isCurrentUser) {
            return const Center(
              child: Text('You have left the queue'),
            );
          }

          final queueLength = queueProvider.getQueueLength(widget.machine.id);
          final queue = queueProvider.getQueueForMachine(widget.machine.id);
          
          // Get user entry (only if still in queue)
          QueueEntry? userEntry;
          if (position != null) {
            try {
              userEntry = queue.firstWhere(
                (entry) => entry.userId == currentUser.matricId,
              );
            } catch (e) {
              // User not found in queue anymore
              userEntry = null;
            }
          }

          int? timeRemaining;
          // If user is in queue and at position 0, show their scan window countdown
          if (position == 0 && userEntry?.expiresAt != null) {
            timeRemaining = userEntry?.timeRemainingInWindow;
          }
          // If user is not in queue but is using the machine, show machine countdown
          else if ((position == null || userEntry == null) && machine?.currentUserId == currentUser.matricId) {
            timeRemaining = machine?.timeRemaining;
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),
                  // Current machine status
                  if (machine != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51), // 20% opacity
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Current User',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            machine.currentUserId ?? 'None',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (machine.timeRemaining != null)
                            Column(
                              children: [
                                const Text(
                                  'Time Left',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${machine.timeRemaining} seconds',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Only show QueuePositionCard if user is in queue (has a position)
                  if (position != null) ...[
                    QueuePositionCard(
                      position: position + 1, // Convert to 1-indexed for display
                      totalInQueue: queueLength,
                      timeRemainingSeconds: timeRemaining,
                      onCancel: () {
                        queueProvider.removeFromQueue(
                          currentUser.matricId,
                          widget.machine.id,
                        );
                        _queueLeft = true;
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (position != null && position > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51), // 20% opacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Queue Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (int i = 0; i < (queueLength > 5 ? 5 : queueLength); i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i == position ? Colors.green : Colors.white.withAlpha(128),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: i == position ? Colors.white : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      i == position ? '← You are here' : 'Waiting...',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (queueLength > 5)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'and ${queueLength - 5} more...',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
