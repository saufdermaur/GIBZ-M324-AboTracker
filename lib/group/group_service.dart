import 'package:squash_tracker/group/group.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final _supabaseClient = Supabase.instance.client.from("groups");

  // Create
  Future createGroup(Group newGroup) async {
    await _supabaseClient.insert(newGroup.toMap());
  }

  // Read
  final stream = Supabase.instance.client.from("groups").stream(primaryKey: [
    "id"
  ]).map((data) => data.map((groupMap) => Group.fromMap(groupMap)).toList());

  // Update
  Future updateGroup(Group oldGroup,String name, int totalCost, int costPerBooking) async {
    await _supabaseClient.update({
      "name": name,
      "total_cost": totalCost,
      "cost_per_booking": costPerBooking
    }).eq("id", oldGroup.id!);
  }

  // Delete
  Future deleteGroup(Group group) async {
    await _supabaseClient.delete().eq("id", group.id!);
  }
}
