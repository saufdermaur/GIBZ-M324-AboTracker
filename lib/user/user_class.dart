class UserClass {
  String id;
  String email;
  String firstName;
  String lastName;

  UserClass(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName});

  factory UserClass.fromMap(Map<String, dynamic> map) {
    return UserClass(
        id: map["id"] as String,
        email: map["email"] as String,
        firstName: map["first_name"] as String,
        lastName: map["last_name"] as String);
  }

  Map<String, dynamic> toMap() {
    return {"email": email, "first_name": firstName, "last_name": lastName};
  }
}
