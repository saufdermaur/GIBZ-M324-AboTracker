class UserGroupClass {
  String id;
  String userId;
  String groupId;
  int cost;

  UserGroupClass({this.id = "", required this.userId, required this.groupId, required this.cost});

  factory UserGroupClass.fromMap(Map<String, dynamic> map) {
    return UserGroupClass(id: map["id"] as String, userId: map["user_id"] as String, groupId: map["group_id"] as String, cost: map["cost"] as int);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"user_id": userId, "group_id": groupId, "cost": cost};
  }
}
