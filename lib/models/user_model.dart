class User {
  final int id;
  final String namaguru;
 

  User({
    required this.id,
    required this.namaguru,
 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      namaguru: json['namaguru'],
 
    );
  }
}