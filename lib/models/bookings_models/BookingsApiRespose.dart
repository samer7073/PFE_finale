import 'package:flutter_application_stage_project/models/bookings_models/BookingsMeta.dart';
import 'package:flutter_application_stage_project/models/bookings_models/bookingsData.dart';
import 'package:flutter_application_stage_project/models/bookings_models/bookingsLinks.dart';

class BookingsApiResponse {
  final List<Bookingsdata> data;
  final BookingsLinks links;
  final Bookingsmeta meta;

  BookingsApiResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory BookingsApiResponse.fromJson(Map<String, dynamic> json) {
    return BookingsApiResponse(
      data: List<Bookingsdata>.from(json['data'].map((x) => Bookingsdata.fromJson(x))),
      links: BookingsLinks.fromJson(json['links']),
      meta: Bookingsmeta.fromJson(json['meta']),
    );
  }
}
