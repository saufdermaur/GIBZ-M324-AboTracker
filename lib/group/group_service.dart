import 'package:abo_tracker/group/group_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final SupabaseQueryBuilder _supabaseClient = Supabase.instance.client.from("groups");

  // Create
  Future<GroupClass> createGroup(GroupClass newGroup) async {
    final PostgrestMap response = await _supabaseClient.insert(newGroup.toMap()).select().single();
    return GroupClass.fromMap(response);
  }

  // Read
  final Stream<List<GroupClass>> stream = Supabase.instance.client.from("groups").stream(primaryKey: <String>["id"]).map(
      (SupabaseStreamEvent data) => data.map((Map<String, dynamic> groupMap) => GroupClass.fromMap(groupMap)).toList());

  // Update
  Future<void> updateGroup(GroupClass oldGroup, String name, int totalCost, int availableUnits) async {
    await _supabaseClient.update(<String, dynamic>{"name": name, "total_cost": totalCost, "available_units": availableUnits}).eq("id", oldGroup.id);
  }

  // Delete
  Future<void> deleteGroup(GroupClass group) async {
    await _supabaseClient.delete().eq("id", group.id);
  }
}
