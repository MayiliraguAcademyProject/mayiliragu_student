enum UserRole {
  admin('ADMIN'),
  student('STUDENT'),
  guest('GUEST');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.guest;
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'STUDENT':
        return UserRole.student;
      case 'GUEST':
      default:
        return UserRole.guest;
    }
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isStudent => this == UserRole.student;
  bool get isGuest => this == UserRole.guest;
}
