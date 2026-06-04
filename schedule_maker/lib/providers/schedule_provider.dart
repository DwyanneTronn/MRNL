import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/class_model.dart';
import 'package:uuid/uuid.dart';

class ScheduleNotifier extends Notifier<List<ClassBlock>> {
  @override
  List<ClassBlock> build() {
    return [
      ClassBlock(
        id: '1',
        name: 'Bogs bogs',
        time: '08:00 AM',
        day: 'Mon',
        location: 'Room 101',
        colorValue: 0xFF64B5F6, // Light Blue
      ),
      ClassBlock(
        id: '2',
        name: 'MRNL 202',
        time: '10:00 AM',
        day: 'Tue',
        location: 'Lab A',
        colorValue: 0xFFFFB74D, // Orange
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
