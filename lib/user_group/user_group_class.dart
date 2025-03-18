class UserGroupClass {
  String id;
  String userId;
  String groupId;

  UserGroupClass({this.id = "", required this.userId, required this.groupId});

  factory UserGroupClass.fromMap(Map<String, dynamic> map) {
    return UserGroupClass(id: map["id"] as String, userId: map["user_id"] as String, groupId: map["group_id"] as String);
  }

  Map<String, dynamic> toMap() {
    return <String, String>{"user_id": userId, "group_id": groupId};
  }
}
