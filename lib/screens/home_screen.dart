import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../providers/auth_provider.dart';
import '../providers/machine_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/machine_card.dart';
import 'qr_scan_screen.dart';
import 'queue_position_screen.dart';
import 'booking_active_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  void _setupDemoQueue() {
    final currentUser = context.read<AuthProvider>().currentUser;
    final machineProvider = context.read<MachineProvider>();
    final queueProvider = context.read<QueueProvider>();

    if (currentUser == null) return;

    // Setup: Add demo users and current user to queue in sequence
    // demo_user_1 will be first to use machine for 15 seconds
    queueProvider.addToQueue('demo_user_1', 'M001');
    queueProvider.addToQueue('demo_user_2', 'M001');
    queueProvider.addToQueue(currentUser.matricId, 'M001');
    queueProvider.addToQueue('demo_user_3', 'M001');

    // Start with demo_user_1 using the machine for 15 seconds
    // After 15 seconds, machine will be free and demo_user_1 will be removed from queue
    machineProvider.setMachineInUse('M001', 'demo_user_1', const Duration(seconds: 10));

    // Immediately mark demo_user_1 as notified (they're the current user)
    queueProvider.markUserAsNotified('demo_user_1', 'M001');

    // Navigate to queue position screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QueuePositionScreen(
          machine: machineProvider.getMachine('M001')!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        // If user has active booking, show the booking screen
        if (bookingProvider.hasActiveBooking) {
          return BookingActiveScreen(
            booking: bookingProvider.activeBooking!,
            machineName: bookingProvider.activeBooking!.machineId,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('SUTD Laundry'),
            backgroundColor: const Color(0xFF00BCD4),
            elevation: 0,
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _setupDemoQueue,
                child: const Text(
                  'Demo Queue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Text(
                        authProvider.currentUser?.name ?? 'User',
                        style: const TextStyle(fontSize: 16),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Tab Bar
              Container(
                color: const Color(0xFF00BCD4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 0 ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Machines',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 1 ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Queues',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: _selectedTabIndex == 0 ? _buildMachinesTab(context) : _buildQueuesTab(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMachinesTab(BuildContext context) {
    return Consumer3<MachineProvider, BookingProvider, QueueProvider>(
      builder: (context, machineProvider, bookingProvider, queueProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Available Machines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: machineProvider.machines.length,
              itemBuilder: (context, index) {
                final machine = machineProvider.machines[index];
                final queueLength = queueProvider.getQueueLength(machine.id);

                return MachineCard(
                  machine: machine,
                  queueLength: queueLength,
                  onTap: () {
                    if (machine.status == MachineStatus.available) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QRScanScreen(
                            machine: machine,
                          ),
                        ),
                      );
                    } else if (machine.status == MachineStatus.inUse) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QueuePositionScreen(
                            machine: machine,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildQueuesTab(BuildContext context) {
    return Consumer2<QueueProvider, AuthProvider>(
      builder: (context, queueProvider, authProvider, _) {

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'My Queues',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MachineProvider>(
              builder: (context, machineProvider, _) {
                final queuedMachines = machineProvider.machines
                    .where((machine) => queueProvider.getQueueLength(machine.id) > 0)
                    .toList();

                if (queuedMachines.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Queues',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All machines are available!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    for (var machine in queuedMachines)
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    machine.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${queueProvider.getQueueLength(machine.id)} in queue',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Time Remaining: ${machine.timeRemaining ?? 0} mins',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => QueuePositionScreen(
                                          machine: machine,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Join Queue'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
