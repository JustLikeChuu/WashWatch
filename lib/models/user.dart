class User {
  final String matricId;
  final String name;

  User({
    required this.matricId,
    required this.name,
  });

  @override
  String toString() => 'User(matricId: $matricId, name: $name)';
}
