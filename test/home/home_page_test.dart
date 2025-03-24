import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:abo_tracker/group/group_class.dart";
import "package:abo_tracker/group/group_service.dart";
import "package:abo_tracker/home/home_page.dart";
import "package:abo_tracker/user/user_class.dart";
import "package:abo_tracker/user/user_service.dart";
import "package:abo_tracker/user_group/user_group_class.dart";
import "package:abo_tracker/user_group/user_group_service.dart";
import "package:mockito/mockito.dart";
import "package:mockito/annotations.dart";

import "home_page_test.mocks.dart";

// Generate mocks using Mockito
@GenerateMocks(<Type>[
  GroupService,
  UserService,
  UserGroupService,
  NavigatorObserver,
])
void main() {
  late StreamController<List<GroupClass>> groupStreamController;

  setUp(() {
    groupStreamController = StreamController<List<GroupClass>>();
  });

  tearDown(() {
    groupStreamController.close();
  });

  testWidgets("Displays list of groups when data is available", (WidgetTester tester) async {
    final MockGroupService mockGroupService = MockGroupService();
    final MockUserService mockUserService = MockUserService();
    final MockUserGroupService mockUserGroupService = MockUserGroupService();

    when(mockGroupService.stream).thenAnswer((_) => groupStreamController.stream);
    groupStreamController.add(<GroupClass>[
      GroupClass(id: "1", name: "Group 1", totalCost: 100, availableUnits: 50),
      GroupClass(id: "2", name: "Group 2", totalCost: 200, availableUnits: 100),
    ]);

    final List<UserClass> users = <UserClass>[
      UserClass(id: "u1", nickname: "User1", email: "user1@email.com"),
      UserClass(id: "u2", nickname: "User2", email: "user2@email.com"),
    ];
    when(mockUserService.getUsers()).thenAnswer((_) async => users);

    final List<UserGroupClass> userGroups = <UserGroupClass>[
      UserGroupClass(userId: "u1", groupId: "1", cost: 10),
      UserGroupClass(userId: "u2", groupId: "1", cost: 20),
    ];
    when(mockUserGroupService.getUserGroups()).thenAnswer((_) async => userGroups);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          groupService: mockGroupService,
          userService: mockUserService,
          userGroupService: mockUserGroupService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Group 1"), findsOneWidget);
    expect(find.text("Group 2"), findsOneWidget);
    expect(find.text("Benutzer: User1, User2"), findsOneWidget);
    expect(find.text("Gesamtkosten: 100.-"), findsOneWidget);
    expect(find.text("Total verfügbare Einheiten: 50"), findsOneWidget);
  });

  testWidgets("Displays correct user nicknames for each group", (WidgetTester tester) async {
    final MockGroupService mockGroupService = MockGroupService();
    final MockUserService mockUserService = MockUserService();
    final MockUserGroupService mockUserGroupService = MockUserGroupService();

    when(mockGroupService.stream).thenAnswer((_) => groupStreamController.stream);
    groupStreamController.add(<GroupClass>[
      GroupClass(id: "1", name: "Group 1", totalCost: 100, availableUnits: 50),
      GroupClass(id: "2", name: "Group 2", totalCost: 200, availableUnits: 100),
    ]);

    final List<UserClass> users = <UserClass>[
      UserClass(id: "u1", nickname: "User1", email: "user1@email.com"),
      UserClass(id: "u2", nickname: "User2", email: "user2@email.com"),
      UserClass(id: "u3", nickname: "User3", email: "user3@email.com"),
    ];
    when(mockUserService.getUsers()).thenAnswer((_) async => users);

    final List<UserGroupClass> userGroups = <UserGroupClass>[
      UserGroupClass(userId: "u1", groupId: "1", cost: 10),
      UserGroupClass(userId: "u2", groupId: "1", cost: 20),
      UserGroupClass(userId: "u3", groupId: "2", cost: 30),
    ];
    when(mockUserGroupService.getUserGroups()).thenAnswer((_) async => userGroups);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          groupService: mockGroupService,
          userService: mockUserService,
          userGroupService: mockUserGroupService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Benutzer: User1, User2"), findsOneWidget);
    expect(find.text("Benutzer: User3"), findsOneWidget);
  });
}
