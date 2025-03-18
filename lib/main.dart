import 'package:flutter/material.dart';
import 'package:squash_tracker/auth/auth_gate.dart';
import 'package:squash_tracker/auth/auth_service.dart';
import 'package:squash_tracker/home/home_page.dart';
import 'package:squash_tracker/user/user_page.dart';
import 'package:squash_tracker/group/group_page.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

void main() async {
  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squash-Tracker',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = GroupPage();
      case 2:
        page = UserPage();
      case 3:
        logOutPage();
        page = Scaffold();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
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
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.group),
                    label: Text('Groups'),
                  ),
                  NavigationRailDestination(icon: Icon(Icons.person), label: Text('Users')),
                  NavigationRailDestination(icon: Icon(Icons.key), label: Text("Sign out"))
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
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

Future<void> logOutPage() async {
  final AuthService authService = AuthService();

  await authService.signOut();
}
