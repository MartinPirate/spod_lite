/// Plain DTO for the currently signed-in end-user (distinct from admins).
///
/// Kept separate from [AdminIdentity] so calling code can't accidentally
/// treat an app user as an admin or vice versa.
class UserIdentity {
  final int id;
  final String email;
  final DateTime? createdAt;

  const UserIdentity({
    required this.id,
    required this.email,
    this.createdAt,
  });

  @override
  String toString() => 'UserIdentity(id: $id, email: $email)';

  @override
  bool operator ==(Object other) =>
      other is UserIdentity && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}
