class ClassBlock {
  final String id;
  final String name;
  final String time; // Display string like "9:00 AM - 10:30 AM"
  final String day;
  final String? location;
  final int colorValue;
  final double startHour; // e.g., 9.5 for 9:30 AM
  final double endHour;   // e.g., 11.0 for 11:00 AM

  ClassBlock({
    required this.id,
    required this.name,
    required this.time,
    required this.day,
    this.location,
    required this.colorValue,
    required this.startHour,
    required this.endHour,
  });

  double get duration => endHour - startHour;

  ClassBlock copyWith({
    String? id,
    String? name,
    String? time,
    String? day,
    String? location,
    int? colorValue,
    double? startHour,
    double? endHour,
  }) {
    return ClassBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      day: day ?? this.day,
      location: location ?? this.location,
      colorValue: colorValue ?? this.colorValue,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }
}
