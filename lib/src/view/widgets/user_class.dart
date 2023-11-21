class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String token;
  final String? code;

  User(
      {this.id,
      required this.firstName,
      required this.lastName,
      required this.token,
      this.code});
}
