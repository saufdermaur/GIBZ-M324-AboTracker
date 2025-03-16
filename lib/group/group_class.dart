class GroupClass {
  String id;
  int? totalCost;
  int? costPerBooking;
  String name;

  GroupClass(
      {this.id = '',
      required this.totalCost,
      required this.costPerBooking,
      required this.name});

  factory GroupClass.fromMap(Map<String, dynamic> map) {
    return GroupClass(
        id: map["id"] as String,
        totalCost: map["total_cost"] as int,
        costPerBooking: map["cost_per_booking"] as int,
        name: map["name"] as String);
  }

  Map<String, dynamic> toMap() {
    return {
      "total_cost": totalCost,
      "cost_per_booking": costPerBooking,
      "name": name
    };
  }
}
