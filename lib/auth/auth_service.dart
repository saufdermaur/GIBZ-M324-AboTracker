import "package:supabase_auth_ui/supabase_auth_ui.dart";

class AuthService {
  final GoTrueClient _supabaseClientAuth = Supabase.instance.client.auth;
  final SupabaseQueryBuilder _supabaseClientUser = Supabase.instance.client.from("users");

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabaseClientAuth.signInWithPassword(email: email, password: password);
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(String nickname, String email, String password) async {
    AuthResponse user = await _supabaseClientAuth.signUp(email: email, password: password);
    await _supabaseClientUser.update(<String, dynamic>{"email": user.user!.email, "nickname": nickname}).eq("id", user.user!.id);
    return user;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseClientAuth.signOut();
  }
}
