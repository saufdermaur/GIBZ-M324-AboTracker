class Group {
  int? id;
  int? totalCost;
  int? costPerBooking;
  String name;

  Group({this.id, required this.totalCost, required this.costPerBooking, required this.name});

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
        id: map["id"] as int,
        totalCost: map["total_cost"] as int,
        costPerBooking: map["cost_per_booking"] as int,
        name: map["name"] as String);
  }

  Map<String, dynamic> toMap() {
    return {"total_cost": totalCost, "cost_per_booking": costPerBooking, "name": name};
  }
}
