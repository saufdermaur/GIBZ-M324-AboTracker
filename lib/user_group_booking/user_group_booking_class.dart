class UserGroupBooking {
  String id;
  String userGroupId;
  String bookingId;

  UserGroupBooking({this.id = "", required this.userGroupId, required this.bookingId});

  factory UserGroupBooking.fromMap(Map<String, dynamic> map) {
    return UserGroupBooking(id: map["id"] as String, userGroupId: map["users_groups_id"] as String, bookingId: map["bookings_id"] as String);
  }

  Map<String, dynamic> toMap() {
    return <String, String>{"users_groups_id": userGroupId, "bookings_id": bookingId};
  }
}
