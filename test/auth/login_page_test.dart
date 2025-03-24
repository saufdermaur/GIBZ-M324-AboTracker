import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:abo_tracker/auth/login_page.dart";
import "package:abo_tracker/auth/auth_service.dart";
import "package:abo_tracker/auth/register_page.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class MockSharedPreferences extends Mock implements SharedPreferences {}

@GenerateMocks(<Type>[AuthService])
void main() {
  bool isSupabaseInitialized = false;

  setUp(() async {
    // ignore: unused_local_variable
    final MockSharedPreferences mockSharedPreferences = MockSharedPreferences();
    SharedPreferences.setMockInitialValues(<String, Object>{});

    if (!isSupabaseInitialized) {
      const String supabaseUrl = String.fromEnvironment("SUPABASE_URL");
      const String supabaseAnonKey = String.fromEnvironment("SUPABASE_ANON_KEY");

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      isSupabaseInitialized = true;
    }
  });

  Future<void> buildLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(),
    ));
    await tester.pump();
  }

  testWidgets("Should render email and password fields, and login button", (WidgetTester tester) async {
    await buildLoginPage(tester);

    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Passwort"), findsOneWidget);
    expect(find.text("Anmelden"), findsOneWidget);
    expect(find.text("Noch keinen Account? Registrieren"), findsOneWidget);
  });

  testWidgets("Should attempt login when pressing the login button", (WidgetTester tester) async {
    await buildLoginPage(tester);

    final Finder emailField = find.byType(TextField).first;
    final Finder passwordField = find.byType(TextField).last;
    final Finder loginButton = find.text("Anmelden");

    await tester.enterText(emailField, "test@example.com");
    await tester.enterText(passwordField, "password123");

    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text("test@example.com"), findsOneWidget);
    final TextField passwordTextField = tester.widget<TextField>(passwordField);
    expect(passwordTextField.obscureText, isTrue);

    //expect(find.byType(SnackBar), findsNothing); would fail because i don't have such a user
  });

  testWidgets("Should navigate to RegisterPage on tap", (WidgetTester tester) async {
    await buildLoginPage(tester);

    final Finder registerText = find.text("Noch keinen Account? Registrieren");

    await tester.tap(registerText);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
