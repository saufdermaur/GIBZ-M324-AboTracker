import 'package:squash_tracker/user/user_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  // Read
  final stream = Supabase.instance.client.from("users").stream(primaryKey: [
    "id"
  ]).map((data) => data.map((userMap) => UserClass.fromMap(userMap)).toList());

}