import "package:abo_tracker/user_group/user_group_class.dart";
import "package:abo_tracker/user_group_booking/user_group_booking_class.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class UserGroupBookingService {
  final SupabaseQueryBuilder _supabaseClient = Supabase.instance.client.from("users_groups_bookings");

  // Create
  Future<void> createUserGroupBookings(String bookingId, List<UserGroupClass> userGroupBooking) async {
    for (UserGroupClass groupBooking in userGroupBooking) {
      await _supabaseClient.insert(<String, String>{"users_groups_id": groupBooking.id, "bookings_id": bookingId});
    }
  }

  // Create simple
  Future<void> createUserGroupBooking(String bookingId, UserGroupClass userGroupBooking) async {
    await _supabaseClient.insert(<String, String>{"users_groups_id": userGroupBooking.id, "bookings_id": bookingId});
  }

  //Read stream
  final Stream<List<UserGroupBooking>> stream = Supabase.instance.client.from("users_groups_bookings").stream(primaryKey: <String>["id"]).map(
      (SupabaseStreamEvent data) => data.map((Map<String, dynamic> userGroupBookingMap) => UserGroupBooking.fromMap(userGroupBookingMap)).toList());

  // Read simple
  Future<List<UserGroupBooking>> getUserGroupBooking(List<UserGroupClass> userGroups) async {
    final List<String> userGroupIds = userGroups.map((UserGroupClass userGroup) => userGroup.id).toList();
    List<UserGroupBooking> bookings = <UserGroupBooking>[];

    for (String userGroupId in userGroupIds) {
      final PostgrestList response = await _supabaseClient.select().eq("users_groups_id", userGroupId);
      bookings.addAll((response as List<dynamic>).map((dynamic map) => UserGroupBooking.fromMap(map as Map<String, dynamic>)).toList());
    }

    return bookings;
  }

  // Update
  Future<void> updateUserGroupBooking(UserGroupBooking oldUserGroup, String userGroupId, String bookingId) async {
    await _supabaseClient.update(<String, String>{"users_groups_id": userGroupId, "bookings_id": bookingId}).eq("id", oldUserGroup.id);
  }

  // Delete
  Future<void> deleteUserGroupBooking(UserGroupBooking userGroup) async {
    await _supabaseClient.delete().eq("id", userGroup.id);
  }
}
