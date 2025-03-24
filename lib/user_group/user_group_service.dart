import "package:abo_tracker/user/user_class.dart";
import "package:abo_tracker/user_group/user_group_class.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class UserGroupService {
  final SupabaseQueryBuilder _supabaseClient = Supabase.instance.client.from("users_groups");

  // Create
  Future<void> createUserGroup(String groupId, List<UserClass> users) async {
    for (UserClass user in users) {
      await _supabaseClient.insert(<String, dynamic>{"user_id": user.id, "group_id": groupId, "cost": 0});
    }
  }

  // Read simple
  Future<List<UserGroupClass>> getUserGroups() async {
    final PostgrestList response = await _supabaseClient.select();
    return (response as List<dynamic>).map((dynamic map) => UserGroupClass.fromMap(map as Map<String, dynamic>)).toList();
  }

  // Read simple id grouo
  Future<List<UserGroupClass>> getUserGroupGroupId(String groupId) async {
    final PostgrestList response = await _supabaseClient.select().eq("group_id", groupId);
    return (response as List<dynamic>).map((dynamic map) => UserGroupClass.fromMap(map as Map<String, dynamic>)).toList();
  }

  // Update
  Future<void> updateUserGroup(UserGroupClass oldUserGroup, String userId, String groupId, int cost) async {
    await _supabaseClient.update(<String, dynamic>{"user_id": userId, "group_id": groupId, "cost": cost}).eq("id", oldUserGroup.id);
  }

  // Update multiple userGroups
  Future<void> updateMultipleUserGroup(List<UserGroupClass> oldUserGroups, int cost) async {
    for (UserGroupClass oldUserGroup in oldUserGroups) {
      await _supabaseClient.update(<String, dynamic>{"cost": oldUserGroup.cost + cost}).eq("id", oldUserGroup.id);
    }
  }

  // Delete
  Future<void> deleteUserGroup(UserGroupClass userGroup) async {
    await _supabaseClient.delete().eq("id", userGroup.id);
  }
}
