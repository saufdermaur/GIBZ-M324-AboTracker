import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:abo_tracker/auth/register_page.dart";
import "package:mockito/annotations.dart";
import "package:abo_tracker/auth/auth_service.dart";
import "package:mockito/mockito.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:supabase_auth_ui/supabase_auth_ui.dart";

class MockSharedPreferences extends Mock implements SharedPreferences {}

// Generate mocks for AuthService and AuthResponse
@GenerateMocks(<Type>[AuthService, AuthResponse])
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

  Future<void> buildRegisterPage(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterPage(),
    ));
    await tester.pump();
  }

  testWidgets("Should render all fields and button", (WidgetTester tester) async {
    await buildRegisterPage(tester);

    // Check that the necessary fields and button are present
    expect(find.text("Benutzername"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Passwort"), findsOneWidget);
    expect(find.text("Passwort bestätigen"), findsOneWidget);
    expect(find.text("Konto erstellen"), findsOneWidget);
  });

  testWidgets("Should show error when passwords do not match", (WidgetTester tester) async {
    await buildRegisterPage(tester);

    // Find the text fields
    final Finder nicknameField = find.byType(TextField).first;
    final Finder emailField = find.byType(TextField).at(1);
    final Finder passwordField = find.byType(TextField).at(2);
    final Finder confirmPasswordField = find.byType(TextField).last;
    final Finder registerButton = find.text("Konto erstellen");

    // Enter the data
    await tester.enterText(nicknameField, "testuser");
    await tester.enterText(emailField, "test@example.com");
    await tester.enterText(passwordField, "password123");
    await tester.enterText(confirmPasswordField, "password456");

    // Tap the Register button
    await tester.tap(registerButton);
    await tester.pump();

    // Check if the error message is displayed
    expect(find.text("Passwörter stimmen nicht überein"), findsOneWidget);
  });
}
