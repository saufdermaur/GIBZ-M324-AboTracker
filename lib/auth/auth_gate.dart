import 'package:flutter/material.dart';
import 'package:squash_tracker/auth/login_page.dart';
import 'package:squash_tracker/main.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (BuildContext context, AsyncSnapshot<AuthState> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final Session? session = snapshot.hasData ? snapshot.data!.session : null;

          if (session != null) {
            return MyHomePage();
          } else {
            return const LoginPage();
          }
        });
  }
}
