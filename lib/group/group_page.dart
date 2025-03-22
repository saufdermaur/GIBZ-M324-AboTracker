import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squash_tracker/group/group_class.dart';
import 'package:squash_tracker/group/group_service.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user/user_service.dart';
import 'package:squash_tracker/user_group/user_group_class.dart';
import 'package:squash_tracker/user_group/user_group_service.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final GroupService _groupDatabase = GroupService();
  final UserService _userDatabase = UserService();
  final UserGroupService _userGroupDatabase = UserGroupService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costPerBookingController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  final List<UserClass> _selectedUsers = <UserClass>[];
  List<UserClass> users = <UserClass>[];
  List<UserGroupClass> userGroups = <UserGroupClass>[];

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void cleanFields() {
    Navigator.pop(context);

    _nameController.clear();
    _costPerBookingController.clear();
    _totalCostController.clear();
    _selectedUsers.clear();

    getUsers();
  }

  void createGroup() async {
    final GroupClass newGroup = GroupClass(
        totalCost: int.parse(_totalCostController.text), availableUnits: int.parse(_costPerBookingController.text), name: _nameController.text);
    try {
      GroupClass group = await _groupDatabase.createGroup(newGroup);
      await _userGroupDatabase.createUserGroup(group.id, _selectedUsers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        cleanFields();
      }
    }
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

  void addNewGroup() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return AlertDialog(
              title: const Text("New Group"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Name"),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _totalCostController,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Abopreis"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _costPerBookingController,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Verfügbare Einheiten"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    Column(
                      children: users.map((UserClass user) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: ChoiceChip(
                            label: Text(user.nickname),
                            selected: _selectedUsers.contains(user),
                            onSelected: (bool selected) {
                              setDialogState(() {
                                if (selected) {
                                  if (!_selectedUsers.any((UserClass u) => u.id == user.id)) {
                                    _selectedUsers.add(user);
                                  }
                                } else {
                                  _selectedUsers.removeWhere((UserClass u) => u.id == user.id);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: cleanFields,
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
            );
          },
        );
      },
    );
  }

  void changeGroup(GroupClass oldGroup, List<UserClass> tempUsersSource, List<UserClass> tempUsersModified) async {
    final int totalCost = int.parse(_totalCostController.text);
    final int availableUnits = int.parse(_costPerBookingController.text);

    try {
      await _groupDatabase.updateGroup(oldGroup, _nameController.text, totalCost, availableUnits);

      for (UserClass user in tempUsersSource) {
        if (!tempUsersModified.contains(user)) {
          await _userGroupDatabase.deleteUserGroup(userGroups.where((UserGroupClass groupClass) => groupClass.groupId == oldGroup.id).first);
        }
      }

      for (UserClass user in tempUsersModified) {
        if (!tempUsersSource.contains(user)) {
          await _userGroupDatabase.createUserGroup(oldGroup.id, <UserClass>[user]);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        cleanFields();
      }
    }
  }

  void updateGroup(GroupClass group) {
    _nameController.text = group.name;
    _costPerBookingController.text = group.availableUnits.toString();
    _totalCostController.text = group.totalCost.toString();
    List<UserClass> tempUsersSource = userGroups
        .where((UserGroupClass userGroup) => userGroup.groupId == group.id)
        .map((UserGroupClass userGroup) => users.firstWhere((UserClass user) => user.id == userGroup.userId))
        .toList();
    List<UserClass> tempUsersModified = userGroups
        .where((UserGroupClass userGroup) => userGroup.groupId == group.id)
        .map((UserGroupClass userGroup) => users.firstWhere((UserClass user) => user.id == userGroup.userId))
        .toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setDialogState) {
              return AlertDialog(
                title: const Text("Edit Group"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Name"),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _totalCostController,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Abopreis"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _costPerBookingController,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Verfügbare Einheiten"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      Column(
                        children: users.map((UserClass user) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: ChoiceChip(
                              label: Text(user.nickname),
                              selected: tempUsersModified.contains(user),
                              onSelected: (bool selected) {
                                setDialogState(() {
                                  if (selected) {
                                    if (!tempUsersModified.any((UserClass u) => u.id == user.id)) {
                                      tempUsersModified.add(user);
                                    }
                                  } else {
                                    tempUsersModified.removeWhere((UserClass u) => u.id == user.id);
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: cleanFields,
                      child: const Text("Abbrechen"),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () => changeGroup(group, tempUsersSource, tempUsersModified),
                      child: const Text("Ändern"),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  void deleteGroupFunction(GroupClass group) async {
    try {
      await _groupDatabase.deleteGroup(group);
      if (mounted) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        cleanFields();
      }
    }
  }

  void deleteGroup(GroupClass group) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Delete Group"),
              actions: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: cleanFields,
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
