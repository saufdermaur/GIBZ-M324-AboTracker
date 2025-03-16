import 'package:squash_tracker/group/group_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final _supabaseClient = Supabase.instance.client.from("groups");

  // Create
  Future createGroup(GroupClass newGroup) async {
    await _supabaseClient.insert(newGroup.toMap());
  }

  // Read
  final stream = Supabase.instance.client.from("groups").stream(primaryKey: [
    "id"
  ]).map((data) => data.map((groupMap) => GroupClass.fromMap(groupMap)).toList());

  // Update
  Future updateGroup(GroupClass oldGroup,String name, int totalCost, int costPerBooking) async {
    await _supabaseClient.update({
      "name": name,
      "total_cost": totalCost,
      "cost_per_booking": costPerBooking
    }).eq("id", oldGroup.id);
  }

  // Delete
  Future deleteGroup(GroupClass group) async {
    await _supabaseClient.delete().eq("id", group.id);
  }
}
