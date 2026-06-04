class ClassBlock {
  final String id;
  final String name;
  final String time;
  final String day;
  final String? location;
  final int colorValue;

  ClassBlock({
    required this.id,
    required this.name,
    required this.time,
    required this.day,
    this.location,
    required this.colorValue,
  });

  ClassBlock copyWith({
    String? id,
    String? name,
    String? time,
    String? day,
    String? location,
    int? colorValue,
  }) {
    return ClassBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      day: day ?? this.day,
      location: location ?? this.location,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
