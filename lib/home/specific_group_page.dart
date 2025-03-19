import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squash_tracker/group/group_class.dart';
import 'package:squash_tracker/group/group_service.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user/user_service.dart';
import 'package:squash_tracker/user_group/user_group_class.dart';
import 'package:squash_tracker/user_group/user_group_service.dart';

class SpecificGroupPage extends StatefulWidget {
  const SpecificGroupPage({super.key});

  @override
  State<SpecificGroupPage> createState() => _SpecificGroupPageState();
}

class _SpecificGroupPageState extends State<SpecificGroupPage> {
  final UserService userDatabase = UserService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costPerBookingController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();

  final List<UserClass> _selectedUsers = <UserClass>[];
  final GroupService _groupDatabase = GroupService();
  final UserService _userDatabase = UserService();
  final UserGroupService _userGroupDatabase = UserGroupService();

  List<UserClass> users = <UserClass>[];
  List<UserGroupClass> userGroups = <UserGroupClass>[];

  void cleanFields() {
    Navigator.pop(context);

    _nameController.clear();
    _costPerBookingController.clear();
    _totalCostController.clear();
    _selectedUsers.clear();

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

  void addNewBooking() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setDialogState) {
              return AlertDialog(
                title: const Text("New Booking"),
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
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Preis pro Mal"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 5.0,
                        children: users.map((UserClass user) {
                          return ChoiceChip(
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
        });
  }

  void createGroup() async {
    final GroupClass newGroup = GroupClass(
        totalCost: int.parse(_totalCostController.text), costPerBooking: int.parse(_costPerBookingController.text), name: _nameController.text);
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

  @override
  Widget build(BuildContext context) {
    List<GroupClass> groups = <GroupClass>[];

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
        body: StreamBuilder<List<GroupClass>>(
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
                            Text('Cost per Booking: \$${group.costPerBooking}'),
                            Text(
                                "Users: ${userGroups.where((UserGroupClass userGroup) => userGroup.groupId == group.id).map((UserGroupClass userGroup) => users.firstWhere((UserClass user) => user.id == userGroup.userId).nickname).join(', ')}")
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: addNewBooking,
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
