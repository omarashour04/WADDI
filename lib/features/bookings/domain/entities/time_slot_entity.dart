import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  const TimeSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [start, end, isAvailable];

  TimeSlot copyWith({
    DateTime? start,
    DateTime? end,
    bool? isAvailable,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
} 