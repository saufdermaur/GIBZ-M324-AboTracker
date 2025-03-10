import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squash_tracker/group/group.dart';
import 'package:squash_tracker/group/group_service.dart';
import 'package:squash_tracker/main.dart';

class EditGroup extends StatefulWidget {
  const EditGroup({super.key});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final groupDatabase = GroupService();

  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _costPerBookingController = TextEditingController();
  final _totalCostController = TextEditingController();

  void create() async {
    final newGroup = Group(
        totalCost: int.parse(_totalCostController.text),
        costPerBooking: int.parse(_costPerBookingController.text),
        name: _nameController.text);

    try {
      await groupDatabase.createGroup(newGroup);
      if (mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gruppen"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
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
                  border: OutlineInputBorder(), labelText: "Benutzer"),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _totalCostController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Abopreis"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _costPerBookingController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Preis pro Mal"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: create,
              child: const Text("Erstellen"),
            ),
          ),
        ],
      ),
    );
  }
}
