import 'package:squash_tracker/user_group/user_group_class.dart';
import 'package:squash_tracker/user_group_booking/user_group_booking_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserGroupBookingService {
  final SupabaseQueryBuilder _supabaseClient = Supabase.instance.client.from("users_groups_bookings");

  // Create
  Future<void> createUserGroupBooking(UserGroupBooking userGroupBooking) async {
    await _supabaseClient.insert(userGroupBooking.toMap());
  }

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
