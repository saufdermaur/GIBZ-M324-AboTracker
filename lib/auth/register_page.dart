import "package:flutter/material.dart";
import "package:abo_tracker/auth/auth_service.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService authService = AuthService();

  // Controllers for the text fields
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Function to handle sign up
  void signUp() async {
    final String nickname = _nicknameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwörter stimmen nicht überein")));
      return;
    }

    try {
      // Attempt to sign up with the provided credentials
      await authService.signUpWithEmailPassword(nickname, email, password);
      if (mounted) {
        Navigator.pop(context); // Navigate back if sign up is successful
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e"))); // Show error message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrieren"), // App bar title
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: <Widget>[
          // Nickname input field
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Benutzername"),
            ),
          ),
          // Email input field
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Email"),
            ),
          ),
          // Password input field
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _passwordController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Passwort"),
              obscureText: true,
            ),
          ),
          // Confirm password input field
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Passwort bestätigen"),
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          // Sign up button
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: signUp,
              child: const Text("Konto erstellen"),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}
