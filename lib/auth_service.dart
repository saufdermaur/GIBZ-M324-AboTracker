import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabaseClient.auth
        .signInWithPassword(email: email, password: password);
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await _supabaseClient.auth.signUp(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Get email
  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
