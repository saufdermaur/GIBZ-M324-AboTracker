import "package:flutter/material.dart";
import "package:abo_tracker/user/user_class.dart";
import "package:abo_tracker/user/user_service.dart";

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Instance of UserService to interact with the user database
  final UserService userDatabase = UserService();

  // Function to clean fields and pop the current context
  void cleanFields() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // List to hold UserClass objects
    List<UserClass> users = <UserClass>[];

    return StreamBuilder<List<UserClass>>(
      // Stream of user data from the database
      stream: userDatabase.stream,
      builder: (BuildContext context, AsyncSnapshot<List<UserClass>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Assign the fetched data to the users list
        users = snapshot.data!;
        return Stack(
          children: <Widget>[
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                UserClass user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(user.nickname),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Email: ${user.email}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
