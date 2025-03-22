class GroupClass {
  String id;
  int? totalCost;
  int? availableUnits;
  String name;

  GroupClass({this.id = "", required this.totalCost, required this.availableUnits, required this.name});

  factory GroupClass.fromMap(Map<String, dynamic> map) {
    return GroupClass(
        id: map["id"] as String, totalCost: map["total_cost"] as int, availableUnits: map["available_units"] as int, name: map["name"] as String);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"total_cost": totalCost, "available_units": availableUnits, "name": name};
  }
}
