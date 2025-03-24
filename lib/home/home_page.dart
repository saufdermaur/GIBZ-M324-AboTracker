import "package:flutter/material.dart";
import "package:abo_tracker/group/group_class.dart";
import "package:abo_tracker/group/group_service.dart";
import "package:abo_tracker/home/specific_group_page.dart";
import "package:abo_tracker/user/user_class.dart";
import "package:abo_tracker/user/user_service.dart";
import "package:abo_tracker/user_group/user_group_class.dart";
import "package:abo_tracker/user_group/user_group_service.dart";

class HomePage extends StatefulWidget {
  final GroupService groupService;
  final UserService userService;
  final UserGroupService userGroupService;

  const HomePage({
    super.key,
    required this.groupService,
    required this.userService,
    required this.userGroupService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GroupService _groupDatabase = widget.groupService;
  late final UserService _userDatabase = widget.userService;
  late final UserGroupService _userGroupDatabase = widget.userGroupService;

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fehler: $e")));
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
        return Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.subscriptions, size: 40),
                      SizedBox(height: 8),
                      Text(
                        "Abo-Tracker",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
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
                          Text("Gesamtkosten: ${group.totalCost}.-"),
                          Text("Total verfügbare Einheiten: ${group.availableUnits}"),
                          Text(
                              "Benutzer: ${userGroups.where((UserGroupClass userGroup) => userGroup.groupId == group.id).map((UserGroupClass userGroup) => users.firstWhere((UserClass user) => user.id == userGroup.userId).nickname).join(', ')}")
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
                                      groupName: group.name,
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
            )
          ],
        );
      },
    );
  }
}
