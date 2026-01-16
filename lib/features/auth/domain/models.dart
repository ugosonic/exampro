class User {
  final String id;
  final String email;
  final String role; // 'user' | 'admin'
  const User({required this.id, required this.email, required this.role});
<<<<<<< HEAD
  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'] as String, email: json['email'] as String, role: json['role'] as String);
=======
  // The backend returns `id` as a number. Coerce to String for app use.
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: '${json['id']}',
        email: json['email'] as String,
        role: json['role'] as String,
      );
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'role': role};
}

class Tokens {
  final String access;
  final String refresh;
  const Tokens({required this.access, required this.refresh});
  factory Tokens.fromJson(Map<String, dynamic> json) =>
      Tokens(access: json['access'] as String, refresh: json['refresh'] as String);
  Map<String, dynamic> toJson() => {'access': access, 'refresh': refresh};
}
