enum MachineStatus { available, inUse, maintenance }

class Machine {
  final String id;
  final String name;
  MachineStatus status;
  String? currentUserId;
  DateTime? inUseUntil;

  Machine({
    required this.id,
    required this.name,
    this.status = MachineStatus.available,
    this.currentUserId,
    this.inUseUntil,
  });

  int? get timeRemaining {
    if (inUseUntil == null) return null;
    return inUseUntil!.difference(DateTime.now()).inSeconds > 0
        ? inUseUntil!.difference(DateTime.now()).inSeconds
        : 0;
  }

  @override
  String toString() => 'Machine(id: $id, name: $name, status: $status)';
}
