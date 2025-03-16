import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squash_tracker/group/group_class.dart';
import 'package:squash_tracker/group/group_service.dart';

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

  void cleanFields() {
    Navigator.pop(context);

    _nameController.clear();
    _userController.clear();
    _costPerBookingController.clear();
    _totalCostController.clear();
  }

  void createGroup() async {
    final newGroup = GroupClass(
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
        cleanFields();
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
            ));
  }

  void changeGroup(GroupClass oldGroup) async {
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
        cleanFields();
      }
    }
  }

  void updateGroup(GroupClass group) {
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
                    onPressed: cleanFields,
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

  void deleteGroupFunction(GroupClass group) async {
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
        cleanFields();
      }
    }
  }

  void deleteGroup(GroupClass group) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Group"),
              actions: [
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
    List<GroupClass> groups = [];

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
