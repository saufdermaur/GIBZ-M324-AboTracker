class UserClass {
  String id;
  String email;
  String nickname;

  UserClass(
      {required this.id,
      required this.email,
      required this.nickname});

  factory UserClass.fromMap(Map<String, dynamic> map) {
    return UserClass(
        id: map["id"] as String,
        email: map["email"] as String,
        nickname: map["nickname"] as String);
  }

  Map<String, dynamic> toMap() {
    return {"email": email, "nickname": nickname};
  }
}
