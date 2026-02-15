import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/class_model.dart';

class ScheduleNotifier extends Notifier<List<ClassBlock>> {
  @override
  List<ClassBlock> build() {
    return [
      ClassBlock(
        id: '1',
        name: 'Math 101',
        time: '08:00 AM',
        day: 'Mon',
        colorValue: 0xFF64B5F6, // Light Blue
      ),
      ClassBlock(
        id: '2',
        name: 'History 202',
        time: '10:00 AM',
        day: 'Tue',
        colorValue: 0xFFFFB74D, // Orange
      ),
      ClassBlock(
        id: '3',
        name: 'Physics 303',
        time: '01:00 PM',
        day: 'Wed',
        colorValue: 0xFF81C784, // Green
      ),
      ClassBlock(
        id: '4',
        name: 'Chemistry 404',
        time: '03:00 PM',
        day: 'Thu',
        colorValue: 0xFF9575CD, // Purple
      ),
      ClassBlock(
        id: '5',
        name: 'Art 505',
        time: '11:00 AM',
        day: 'Fri',
        colorValue: 0xFFE57373, // Red
      ),
    ];
  }
}

final scheduleProvider =
    NotifierProvider<ScheduleNotifier, List<ClassBlock>>(ScheduleNotifier.new);
