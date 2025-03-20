class BookingClass {
  String id;
  DateTime time;

  BookingClass({this.id = "", required this.time});

  factory BookingClass.fromMap(Map<String, dynamic> map) {
    return BookingClass(id: map["id"] as String, time: DateTime.parse(map["time"] as String));
  }

  Map<String, dynamic> toMap() {
    return <String, String>{
      "time": time.toIso8601String(),
    };
  }
}
