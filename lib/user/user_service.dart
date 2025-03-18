import 'package:squash_tracker/user/user_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseQueryBuilder _supabaseClient = Supabase.instance.client.from("users");

  // Read Stream
  final Stream<List<UserClass>> stream = Supabase.instance.client.from("users").stream(
      primaryKey: <String>["id"]).map((SupabaseStreamEvent data) => data.map((Map<String, dynamic> userMap) => UserClass.fromMap(userMap)).toList());

  // Read simple
  Future<List<UserClass>> getUsers() async {
    final PostgrestList response = await _supabaseClient.select();
    return (response as List<dynamic>).map((dynamic map) => UserClass.fromMap(map)).toList();
  }
}
