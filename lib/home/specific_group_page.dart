import 'package:flutter/material.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user/user_service.dart';

class SpecificGroupPage extends StatefulWidget {
  const SpecificGroupPage({super.key});

  @override
  State<SpecificGroupPage> createState() => _SpecificGroupPageState();
}

class _SpecificGroupPageState extends State<SpecificGroupPage> {
  final UserService userDatabase = UserService();

  void cleanFields() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Specific Group'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<List<UserClass>>(
        stream: userDatabase.stream,
        builder: (BuildContext context, AsyncSnapshot<List<UserClass>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<UserClass> users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              UserClass user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(user.nickname),
                  subtitle: Text('Email: ${user.email}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
