import 'package:flutter/material.dart';
import 'package:squash_tracker/group/group_class.dart';
import 'package:squash_tracker/group/group_service.dart';
import 'package:squash_tracker/home/specific_group_page.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user/user_service.dart';
import 'package:squash_tracker/user_group/user_group_class.dart';
import 'package:squash_tracker/user_group/user_group_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GroupService _groupDatabase = GroupService();
  final UserService _userDatabase = UserService();
  final UserGroupService _userGroupDatabase = UserGroupService();

  List<UserClass> users = <UserClass>[];
  List<UserGroupClass> userGroups = <UserGroupClass>[];

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    try {
      final List<UserClass> fetchedUsers = await _userDatabase.getUsers();
      final List<UserGroupClass> fetchedUserGroups = await _userGroupDatabase.getUserGroups();
      if (mounted) {
        setState(() {
          users = fetchedUsers;
          userGroups = fetchedUserGroups;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GroupClass> groups = <GroupClass>[];

    return StreamBuilder<List<GroupClass>>(
      stream: _groupDatabase.stream,
      builder: (BuildContext context, AsyncSnapshot<List<GroupClass>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        groups = snapshot.data!;
        return Stack(
          children: <Widget>[
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: groups.length,
              itemBuilder: (BuildContext context, int index) {
                GroupClass group = groups[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Total Cost: \$${group.totalCost}'),
                        Text('Total verfügbare Einheiten: ${group.availableUnits}'),
                        Text(
                            "Users: ${userGroups.where((UserGroupClass userGroup) => userGroup.groupId == group.id).map((UserGroupClass userGroup) => users.firstWhere((UserClass user) => user.id == userGroup.userId).nickname).join(', ')}")
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<SpecificGroupPage>(
                                  builder: (BuildContext context) => SpecificGroupPage(
                                    userGroupClass: userGroups.firstWhere((UserGroupClass userGroup) => userGroup.groupId == group.id),
                                    usersClass: userGroups
                                        .where((UserGroupClass userGroup) => userGroup.groupId == group.id)
                                        .map((UserGroupClass userGroup) => users.firstWhere((UserClass user) => user.id == userGroup.userId))
                                        .toList(),
                                    totalCost: group.totalCost!,
                                    availableUnits: group.availableUnits!,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
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
