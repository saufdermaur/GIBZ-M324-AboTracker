import "package:abo_tracker/booking/booking_class.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class BookingService {
  final SupabaseQueryBuilder _supabaseClient = Supabase.instance.client.from("bookings");

  // Create
  Future<BookingClass> createBooking(BookingClass newBooking) async {
    final PostgrestMap response = await _supabaseClient.insert(newBooking.toMap()).select().single();
    return BookingClass.fromMap(response);
  }

  // Read stream
  final Stream<List<BookingClass>> stream = Supabase.instance.client.from("bookings").stream(primaryKey: <String>["id"]).map(
      (SupabaseStreamEvent data) => data.map((Map<String, dynamic> groupMap) => BookingClass.fromMap(groupMap)).toList());

  // Read simple
  Future<List<BookingClass>> getBookings() async {
    final PostgrestList response = await _supabaseClient.select();
    return (response as List<dynamic>).map((dynamic map) => BookingClass.fromMap(map as Map<String, dynamic>)).toList();
  }

  // Update
  Future<void> updateBooking(BookingClass oldBooking, DateTime time) async {
    await _supabaseClient.update(<String, dynamic>{"time": time.toIso8601String()}).eq("id", oldBooking.id);
  }

  // Delete
  Future<void> deleteBooking(BookingClass oldBooking) async {
    await _supabaseClient.delete().eq("id", oldBooking.id);
  }
}
