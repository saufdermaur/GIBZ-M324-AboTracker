import "package:flutter/material.dart";
import "package:abo_tracker/auth/login_page.dart";
import "package:abo_tracker/main.dart";
import "package:supabase_auth_ui/supabase_auth_ui.dart";

// AuthGate widget to handle authentication state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
        // Listen to authentication state changes
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (BuildContext context, AsyncSnapshot<AuthState> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Get the current session if available
          final Session? session = snapshot.hasData ? snapshot.data!.session : null;

          // If session exists, navigate to MyHomePage, otherwise show LoginPage
          if (session != null) {
            return MyHomePage();
          } else {
            return const LoginPage();
          }
        });
  }
}
