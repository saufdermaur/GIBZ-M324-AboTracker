class BookingClass {
  String id;
  DateTime time;

  BookingClass({this.id = "", required this.time});

  factory BookingClass.fromMap(Map<String, dynamic> map) {
    return BookingClass(id: map["id"] as String, time: map["time"] as DateTime);
  }

  Map<String, dynamic> toMap() {
    return <String, DateTime>{"time": time};
  }
}
