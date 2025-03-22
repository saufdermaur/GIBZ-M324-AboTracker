import 'package:flutter/material.dart';
import 'package:squash_tracker/booking/booking_class.dart';
import 'package:squash_tracker/booking/booking_service.dart';
import 'package:squash_tracker/user/user_class.dart';
import 'package:squash_tracker/user_group/user_group_class.dart';
import 'package:squash_tracker/user_group/user_group_service.dart';
import 'package:squash_tracker/user_group_booking/user_group_booking_class.dart';
import 'package:squash_tracker/user_group_booking/user_group_booking_service.dart';

class SpecificGroupPage extends StatefulWidget {
  final UserGroupClass userGroupClass;
  final List<UserClass> usersClass;
  final int totalCost;
  final int availableUnits;

  SpecificGroupPage({super.key, required this.userGroupClass, required this.usersClass, required this.totalCost, required this.availableUnits});

  @override
  State<SpecificGroupPage> createState() => _SpecificGroupPageState();
}

class _SpecificGroupPageState extends State<SpecificGroupPage> {
  late final UserGroupClass userGroupClass;
  late final List<UserClass> usersClass;
  late final int totalCost;
  late final int availableUnits;
  late int costPerBooking;

  final TextEditingController _dateController = TextEditingController();

  final List<UserClass> _selectedUsers = <UserClass>[];
  final UserGroupService _userGroupDatabase = UserGroupService();
  final UserGroupBookingService _userGroupBookingDatabase = UserGroupBookingService();
  final BookingService _bookingDatabase = BookingService();

  List<UserGroupClass> userGroups = <UserGroupClass>[];
  List<BookingClass> bookings = <BookingClass>[];
  List<UserGroupBooking> userGroupBookings = <UserGroupBooking>[];
  List<UserClass> usersOfGroup = <UserClass>[];

  @override
  void initState() {
    super.initState();
    userGroupClass = widget.userGroupClass;
    usersClass = widget.usersClass;
    totalCost = widget.totalCost;
    availableUnits = widget.availableUnits;
    costPerBooking = (totalCost / availableUnits).round();

    getUsers();
  }

  void cleanFields(bool fetchUsers) {
    Navigator.pop(context);

    _dateController.clear();
    _selectedUsers.clear();

    if (fetchUsers) {
      getUsers();
    }
  }

  Future<void> getUsers() async {
    try {
      final List<UserGroupClass> fetchedUserGroups = await _userGroupDatabase.getUserGroupGroupId(userGroupClass.groupId);
      final List<BookingClass> fetchedBookings = await _bookingDatabase.getBookings();
      final List<UserGroupBooking> fetchedUserGroupBookings = await _userGroupBookingDatabase.getUserGroupBooking(fetchedUserGroups);

      if (mounted) {
        setState(() {
          userGroups = fetchedUserGroups;
          bookings = fetchedBookings;
          userGroupBookings = fetchedUserGroupBookings;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void addNewBooking() {
    _dateController.text = DateTime.now().toLocal().toString().split(' ')[0];

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
                            controller: _dateController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Datum",
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                                });
                              }
                            },
                          )),
                      Column(
                        children: usersClass.map((UserClass user) {
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
                      onPressed: () => cleanFields(false),
                      child: const Text("Abbrechen"),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: createBooking,
                      child: const Text("Erstellen"),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  void createBooking() async {
    final BookingClass newBooking = BookingClass(time: DateTime.parse(_dateController.text));

    try {
      BookingClass booking = await _bookingDatabase.createBooking(newBooking);

      final List<UserGroupClass> mappedUserGroups = _selectedUsers.expand((UserClass user) {
        return userGroups.where((UserGroupClass group) => group.userId == user.id).toList();
      }).toList();

      await _userGroupBookingDatabase.createUserGroupBookings(booking.id, mappedUserGroups);
      await _userGroupDatabase.updateMultipleUserGroup(mappedUserGroups, costPerBooking);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        cleanFields(true);
      }
    }
  }

  void updateNewBooking(BookingClass booking) {
    _dateController.text = booking.time.toString().split(' ')[0];

    List<UserClass> test = userGroupBookings
        .where((UserGroupBooking userGroupBooking) => userGroupBooking.bookingId == booking.id)
        .map((UserGroupBooking userGroupBooking) {
      return usersClass.firstWhere(
          (UserClass user) => user.id == userGroups.firstWhere((UserGroupClass group) => group.id == userGroupBooking.userGroupId).userId);
    }).toList();

    List<UserClass> tempUsersSource = List<UserClass>.from(test);
    List<UserClass> tempUsersModified = List<UserClass>.from(test);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setDialogState) {
              return AlertDialog(
                title: const Text("Update Booking"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Datum",
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: booking.time,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                                });
                              }
                            },
                          )),
                      Column(
                        children: usersClass.map((UserClass user) {
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
                      onPressed: () => cleanFields(false),
                      child: const Text("Abbrechen"),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () => changeBooking(booking, tempUsersSource, tempUsersModified),
                      child: const Text("Ändern"),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  void changeBooking(BookingClass oldBooking, List<UserClass> tempUsersSource, List<UserClass> tempUsersModified) async {
/*
    final List<UserGroupClass> mappedUserGroups = tempUsersModified.map((UserClass user) {
      return userGroups.firstWhere((UserGroupClass group) => group.userId == user.id);
    }).toList();
    */

    try {
      for (UserClass user in tempUsersSource) {
        if (!tempUsersModified.contains(user)) {
          UserGroupClass test = userGroups.firstWhere((UserGroupClass group) => group.userId == user.id);
          await _userGroupBookingDatabase
              .deleteUserGroupBooking(userGroupBookings.firstWhere((UserGroupBooking userGroupBooking) => userGroupBooking.userGroupId == test.id));
          await _userGroupDatabase.updateUserGroup(test, test.userId, test.groupId, -costPerBooking);
        }
      }

      for (UserClass user in tempUsersModified) {
        if (!tempUsersSource.contains(user)) {
          UserGroupClass test = userGroups.firstWhere((UserGroupClass group) => group.userId == user.id);
          await _userGroupBookingDatabase.createUserGroupBooking(oldBooking.id, test);
          await _userGroupDatabase.updateUserGroup(test, test.id, test.groupId, costPerBooking);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        cleanFields(true);
      }
    }
  }

  void deleteGroupFunction(BookingClass booking) async {
    try {
      final List<UserGroupClass> mappedUserGroups = userGroupBookings
          .where((UserGroupBooking userGroupBooking) => userGroupBooking.bookingId == booking.id)
          .map((UserGroupBooking userGroupBooking) {
        final UserGroupClass userGroup = userGroups.firstWhere((UserGroupClass group) => group.id == userGroupBooking.userGroupId);
        return userGroup;
      }).toList();

      await _userGroupDatabase.updateMultipleUserGroup(mappedUserGroups, -costPerBooking);
      await _bookingDatabase.deleteBooking(booking); // is enough because we cascade

      if (mounted) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        cleanFields(true);
      }
    }
  }

  void deleteGroup(BookingClass booking) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("Delete Group"),
              actions: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () => cleanFields(false),
                    child: const Text("Abbrechen"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () => deleteGroupFunction(booking),
                    child: const Text("Löschen"),
                  ),
                ),
              ],
            ));
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
      body: FutureBuilder<List<BookingClass>>(
        future: _bookingDatabase.getBookings(),
        builder: (BuildContext context, AsyncSnapshot<List<BookingClass>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || usersClass.isEmpty || userGroups.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          bookings = snapshot.data!;

          if (userGroupBookings.isEmpty) {
            return Center(
              child: Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: addNewBooking,
                  child: Icon(Icons.add),
                ),
              ),
            );
          }

          bookings = snapshot.data!;
          final List<String> uniqueBookingIds = userGroupBookings.map((UserGroupBooking e) => e.bookingId).toSet().toList();

          uniqueBookingIds.sort((String a, String b) {
            final DateTime timeA = bookings.firstWhere((BookingClass booking) => booking.id == a).time;
            final DateTime timeB = bookings.firstWhere((BookingClass booking) => booking.id == b).time;
            return timeA.compareTo(timeB);
          });

          int intermediateCost = totalCost;
          int intermediateAvailableUnits = availableUnits;

          return Stack(
            children: <Widget>[
              ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: uniqueBookingIds.length,
                itemBuilder: (BuildContext context, int index) {
                  final String bookingId = uniqueBookingIds[index];
                  final BookingClass booking = bookings.firstWhere((BookingClass b) => b.id == bookingId);

                  final DateTime bookingTime = booking.time;
                  final List<String> usersForBooking = userGroupBookings
                      .where((UserGroupBooking userGroupBooking) => userGroupBooking.bookingId == bookingId)
                      .map((UserGroupBooking userGroupBooking) {
                    final UserGroupClass userGroup = userGroups.firstWhere((UserGroupClass group) => group.id == userGroupBooking.userGroupId);
                    final UserClass user = usersClass.firstWhere((UserClass u) => u.id == userGroup.userId);
                    return user.nickname;
                  }).toList();

                  intermediateCost -= 25;
                  intermediateAvailableUnits -= 1;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Buchung: ${bookingTime.toLocal().toString().split(' ')[0]}"),
                      subtitle: Text("Users: ${usersForBooking.join(', ')}"),
                      trailing: SizedBox(
                        width: 250,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text("Saldo: $intermediateCost"),
                                    Text("Verbleibend: $intermediateAvailableUnits"),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => updateNewBooking(booking),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => deleteGroup(booking),
                              icon: const Icon(Icons.delete),
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
                  onPressed: addNewBooking,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
