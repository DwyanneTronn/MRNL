import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/class_model.dart';

class ScheduleNotifier extends Notifier<List<ClassBlock>> {
  @override
  List<ClassBlock> build() {
    return [
      ClassBlock(
        id: '1',
        name: 'PHILO 13',
        time: '9:30 AM - 11:00 AM',
        day: 'Mon',
        colorValue: 0xFF8BC34A, // Light Green
        startHour: 9.5,
        endHour: 11.0,
      ),
      ClassBlock(
        id: '2',
        name: 'PHILO 13',
        time: '9:30 AM - 11:00 AM',
        day: 'Thu',
        colorValue: 0xFF8BC34A,
        startHour: 9.5,
        endHour: 11.0,
      ),
      ClassBlock(
        id: '3',
        name: 'MSYS 51',
        time: '3:30 PM - 5:00 PM',
        day: 'Mon',
        colorValue: 0xFFBA68C8, // Purple
        startHour: 15.5,
        endHour: 17.0,
      ),
      ClassBlock(
        id: '4',
        name: 'MSYS 51',
        time: '3:30 PM - 5:00 PM',
        day: 'Thu',
        colorValue: 0xFFBA68C8,
        startHour: 15.5,
        endHour: 17.0,
      ),
      ClassBlock(
        id: '5',
        name: 'SocSc 13',
        time: '6:30 PM - 8:00 PM',
        day: 'Mon',
        colorValue: 0xFFFFB74D, // Orange
        startHour: 18.5,
        endHour: 20.0,
      ),
      ClassBlock(
        id: '6',
        name: 'SocSc 13',
        time: '6:30 PM - 8:00 PM',
        day: 'Thu',
        colorValue: 0xFFFFB74D,
        startHour: 18.5,
        endHour: 20.0,
      ),
      ClassBlock(
        id: '7',
        name: 'MSYS 42',
        time: '12:30 PM - 2:00 PM',
        day: 'Tue',
        colorValue: 0xFFFFD54F, // Amber
        startHour: 12.5,
        endHour: 14.0,
      ),
      ClassBlock(
        id: '8',
        name: 'MSYS 42',
        time: '12:30 PM - 2:00 PM',
        day: 'Fri',
        colorValue: 0xFFFFD54F,
        startHour: 12.5,
        endHour: 14.0,
      ),
      ClassBlock(
        id: '9',
        name: 'ITMGT 46',
        time: '3:30 PM - 5:00 PM',
        day: 'Tue',
        colorValue: 0xFFA5D6A7, // Green 200
        startHour: 15.5,
        endHour: 17.0,
      ),
      ClassBlock(
        id: '10',
        name: 'ITMGT 46',
        time: '3:30 PM - 5:00 PM',
        day: 'Fri',
        colorValue: 0xFFA5D6A7,
        startHour: 15.5,
        endHour: 17.0,
      ),
      ClassBlock(
        id: '11',
        name: 'NSTP 12',
        time: '8:00 AM - 12:00 PM',
        day: 'Wed',
        colorValue: 0xFFF8BBD0, // Pink 100
        startHour: 8.0,
        endHour: 12.0,
      ),
      ClassBlock(
        id: '12',
        name: 'ISCS 30.13',
        time: '11:00 AM - 12:00 PM',
        day: 'Fri',
        colorValue: 0xFFE57373, // Red 300
        startHour: 11.0,
        endHour: 12.0,
      ),
      ClassBlock(
        id: '13',
        name: 'CSCI 111',
        time: '11:00 AM - 2:00 PM',
        day: 'Sat',
        colorValue: 0xFF4DB6AC, // Teal 300
        startHour: 11.0,
        endHour: 14.0,
      ),
    ];
  }

  void addClass(ClassBlock newClass) {
    state = [...state, newClass];
  }

  void updateClass(ClassBlock updatedClass) {
    state = [
      for (final item in state)
        if (item.id == updatedClass.id) updatedClass else item
    ];
  }

  void deleteClass(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final scheduleProvider =
    NotifierProvider<ScheduleNotifier, List<ClassBlock>>(ScheduleNotifier.new);
