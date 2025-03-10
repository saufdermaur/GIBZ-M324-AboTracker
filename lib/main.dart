import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:squash_tracker/group/add_group.dart';
import 'package:squash_tracker/auth/auth_gate.dart';
import 'package:squash_tracker/auth/auth_service.dart';
import 'package:squash_tracker/group/group.dart';
import 'package:squash_tracker/group/group_service.dart';
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
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Squash-Tracker',
        theme: ThemeData.dark(
          useMaterial3: true,
        ),
        home: AuthGate(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = GroupPage();
      case 3:
        logOutPage();
        page = Scaffold();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.group),
                    label: Text('Groups'),
                  ),
                  NavigationRailDestination(
                      icon: Icon(Icons.key), label: Text("Sign out"))
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
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

Future logOutPage() async {
  final authService = AuthService();

  await authService.signOut();
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ' '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final groupDatabase = GroupService();

  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _costPerBookingController = TextEditingController();
  final _totalCostController = TextEditingController();

  void createGroup() async {
    final newGroup = Group(
        totalCost: int.parse(_totalCostController.text),
        costPerBooking: int.parse(_costPerBookingController.text),
        name: _nameController.text);

    try {
      await groupDatabase.createGroup(newGroup);
      if (mounted) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);

        _nameController.clear();
        _userController.clear();
        _costPerBookingController.clear();
        _totalCostController.clear();
      }
    }
  }

  void addNewGroup() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("New Group"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: "Name"),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _userController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Benutzer"),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _totalCostController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Abopreis"),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _costPerBookingController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Preis pro Mal"),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _nameController.clear();
                      _userController.clear();
                      _costPerBookingController.clear();
                      _totalCostController.clear();
                    },
                    child: const Text("Abbrechen"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: createGroup,
                    child: const Text("Erstellen"),
                  ),
                ),
              ],
            ));
  }

  void changeGroup(Group oldGroup) async {
    final totalCost = int.parse(_totalCostController.text);
    final costPerBooking = int.parse(_costPerBookingController.text);

    try {
      await groupDatabase.updateGroup(
          oldGroup, _nameController.text, totalCost, costPerBooking);
      if (mounted) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);

        _nameController.clear();
        _userController.clear();
        _costPerBookingController.clear();
        _totalCostController.clear();
      }
    }
  }

  void updateGroup(Group group) {
    _nameController.text = group.name;
    //_userController.text = group.user;
    _costPerBookingController.text = group.costPerBooking.toString();
    _totalCostController.text = group.totalCost.toString();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Edit Group"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: "Name"),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _userController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Benutzer"),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _totalCostController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Abopreis"),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _costPerBookingController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Preis pro Mal"),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _nameController.clear();
                      _userController.clear();
                      _costPerBookingController.clear();
                      _totalCostController.clear();
                    },
                    child: const Text("Abbrechen"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () => changeGroup(group),
                    child: const Text("Ändern"),
                  ),
                ),
              ],
            ));
  }

  void deleteGroupFunction(Group group) async {
    try {
      await groupDatabase.deleteGroup(group);
      if (mounted) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);

        _nameController.clear();
        _userController.clear();
        _costPerBookingController.clear();
        _totalCostController.clear();
      }
    }
  }

  void deleteGroup(Group group) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Group"),
              actions: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _nameController.clear();
                      _userController.clear();
                      _costPerBookingController.clear();
                      _totalCostController.clear();
                    },
                    child: const Text("Abbrechen"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () => deleteGroupFunction(group),
                    child: const Text("Löschen"),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    List<Group> groups = [];

    return StreamBuilder(
      stream: groupDatabase.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        groups = snapshot.data!;
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                var group = groups[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Cost: \$${group.totalCost}'),
                        Text('Cost per Booking: \$${group.costPerBooking}'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => updateGroup(group),
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => deleteGroup(group),
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: addNewGroup,
                child: Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
