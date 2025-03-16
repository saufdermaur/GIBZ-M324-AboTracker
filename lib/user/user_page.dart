import 'package:flutter/material.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user/user_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final userDatabase = UserService();

  void cleanFields() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<UserClass> users = [];

    return StreamBuilder(
      stream: userDatabase.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        users = snapshot.data!;
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("${user.firstName} ${user.lastName}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
