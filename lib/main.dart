import "package:abo_tracker/group/group_service.dart";
import "package:abo_tracker/user/user_service.dart";
import "package:abo_tracker/user_group/user_group_service.dart";
import "package:flutter/material.dart";
import "package:abo_tracker/auth/auth_gate.dart";
import "package:abo_tracker/auth/auth_service.dart";
import "package:abo_tracker/home/home_page.dart";
import "package:abo_tracker/user/user_page.dart";
import "package:abo_tracker/group/group_page.dart";
import "package:supabase_auth_ui/supabase_auth_ui.dart";
import "package:flutter_localizations/flutter_localizations.dart";

void main() async {
  const String supabaseUrl = String.fromEnvironment("SUPABASE_URL");
  const String supabaseAnonKey = String.fromEnvironment("SUPABASE_ANON_KEY");

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Abo-Tracker",
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: <Locale>[
        Locale("de", "CH"),
      ],
      home: AuthGate(), // Show AuthGate as the home page
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // Track the selected index for NavigationRail

  @override
  Widget build(BuildContext context) {
    Widget page;
    // Determine which page to show based on selectedIndex
    switch (selectedIndex) {
      case 0:
        page = HomePage(
          groupService: GroupService(),
          userService: UserService(),
          userGroupService: UserGroupService(),
        );
      case 1:
        page = GroupPage();
      case 2:
        page = UserPage();
      case 3:
        logOutPage();
        page = Scaffold();
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text("Startseite"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.group),
                    label: Text("Gruppen"),
                  ),
                  NavigationRailDestination(icon: Icon(Icons.person), label: Text("Benutzer")),
                  NavigationRailDestination(icon: Icon(Icons.key), label: Text("Abmelden"))
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (int value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // Display the selected page
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Function to handle user logout
Future<void> logOutPage() async {
  final AuthService authService = AuthService();

  await authService.signOut();
}
