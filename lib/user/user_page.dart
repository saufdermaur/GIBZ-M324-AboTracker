import 'package:flutter/material.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user/user_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService userDatabase = UserService();

  void cleanFields() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<UserClass> users = <UserClass>[];

    return StreamBuilder<List<UserClass>>(
      stream: userDatabase.stream,
      builder: (BuildContext context, AsyncSnapshot<List<UserClass>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

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
                        Text('Email: ${user.email}'),
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
