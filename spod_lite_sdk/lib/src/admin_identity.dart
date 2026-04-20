/// Plain DTO for the currently signed-in admin.
///
/// The SDK is generic and must not leak your per-project generated types,
/// so we expose an [AdminIdentity] regardless of what `AdminUser` looks like
/// in your project's generated client.
class AdminIdentity {
  final int id;
  final String email;
  final DateTime? createdAt;

  const AdminIdentity({
    required this.id,
    required this.email,
    this.createdAt,
  });

  @override
  String toString() => 'AdminIdentity(id: $id, email: $email)';

  @override
  bool operator ==(Object other) =>
      other is AdminIdentity && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}
