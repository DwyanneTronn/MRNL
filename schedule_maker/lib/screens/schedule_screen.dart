import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/schedule_provider.dart';
import '../providers/background_provider.dart';
import '../models/class_model.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      ref.read(backgroundProvider.notifier).setPendingImage(pickedFile.path);
    }
  }

  void _showClassDialog(BuildContext context, WidgetRef ref, [ClassBlock? classBlock]) {
    final isEditing = classBlock != null;
    final nameController = TextEditingController(text: classBlock?.name);
    final dayController = TextEditingController(text: classBlock?.day ?? 'Mon');
    final locationController = TextEditingController(text: classBlock?.location);
    
    TimeOfDay startTime = classBlock != null 
        ? TimeOfDay(hour: classBlock.startHour.toInt(), minute: ((classBlock.startHour % 1) * 60).round())
        : const TimeOfDay(hour: 9, minute: 0);
    
    TimeOfDay endTime = classBlock != null
        ? TimeOfDay(hour: classBlock.endHour.toInt(), minute: ((classBlock.endHour % 1) * 60).round())
        : const TimeOfDay(hour: 10, minute: 30);

    int selectedColor = classBlock?.colorValue ?? 0xFF64B5F6;

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Class' : 'Add Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Class Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: dayController.text,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (val) => setState(() => dayController.text = val!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: startTime);
                    if (picked != null) setState(() => startTime = picked);
                  },
                ),
                ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(endTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: endTime);
                    if (picked != null) setState(() => endTime = picked);
                  },
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location (Optional)'),
                ),
                const SizedBox(height: 16),
                const Text('Select Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    0xFF64B5F6,
                    0xFF81C784,
                    0xFFFFD54F,
                    0xFFFF8A65,
                    0xFFBA68C8,
                    0xFFF06292,
                    0xFF8BC34A,
                  ].map((color) => _colorOption(color, selectedColor, (val) {
                    setState(() => selectedColor = val);
                  })).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            if (isEditing)
              TextButton(
                onPressed: () {
                  ref.read(scheduleProvider.notifier).deleteClass(classBlock.id);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a class name'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final startDouble = startTime.hour + (startTime.minute / 60.0);
                final endDouble = endTime.hour + (endTime.minute / 60.0);
                
                if (endDouble <= startDouble) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End time must be after start time'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final newClass = ClassBlock(
                  id: isEditing ? classBlock.id : const Uuid().v4(),
                  name: nameController.text.trim(),
                  time: '${startTime.format(context)} - ${endTime.format(context)}',
                  day: dayController.text,
                  location: locationController.text,
                  colorValue: selectedColor,
                  startHour: startDouble,
                  endHour: endDouble,
                );

                final conflict = ref.read(scheduleProvider.notifier).getConflictingClass(
                  newClass, 
                  ignoreId: isEditing ? classBlock.id : null,
                );

                if (conflict != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Conflict detected with ${conflict.name} (${conflict.time}) on ${conflict.day}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  ref.read(scheduleProvider.notifier).updateClass(newClass);
                } else {
                  ref.read(scheduleProvider.notifier).addClass(newClass);
                }
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorOption(int color, int selected, Function(int) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          border: selected == color ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundState = ref.watch(backgroundProvider);
    final schedule = ref.watch(scheduleProvider);

    final String? displayImagePath =
        backgroundState.pendingImagePath ?? backgroundState.savedImagePath;
    final bool hasPendingChanges = backgroundState.pendingImagePath != null;

    // 1. Setup the Time Range (8 AM to 8 PM based on your image)
    final timeSlots = [
      '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', 
      '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', 
      '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // 2. Configuration for the layout
    const double hourHeight = 60.0;
    const double timeColumnWidth = 60.0;

    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Background Image
          Positioned.fill(
            child: displayImagePath != null
                ? (displayImagePath.startsWith('http') ||
                        displayImagePath.startsWith('blob:') ||
                        kIsWeb
                    ? Image.network(
                        displayImagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.error, color: Colors.white)),
                      )
                    : Image.file(
                        File(displayImagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.error, color: Colors.white)),
                      ))
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      ),
                    ),
                  ),
          ),
          // LAYER 2: Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          // LAYER 3: Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
          // LAYER 4: Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Schedule',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (!hasPendingChanges) ...[
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
                              onPressed: () => _showClassDialog(context, ref),
                              tooltip: 'Add Class',
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_library, color: Colors.white),
                              onPressed: () => _pickImage(ref),
                              tooltip: 'Change Background',
                            ),
                          ] else ...[
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => ref
                                  .read(backgroundProvider.notifier)
                                  .saveChanges(),
                              tooltip: 'Save Background',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => ref
                                  .read(backgroundProvider.notifier)
                                  .cancelChanges(),
                              tooltip: 'Cancel',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // DAYS HEADER (Mon - Sat)
                  Row(
                    children: [
                      SizedBox(width: timeColumnWidth), // Spacing for time column
                      ...days.map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                  
                  const SizedBox(height: 10),

                  // SCROLLABLE TIMETABLE AREA
                  Expanded(
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A. TIME COLUMN (Left side)
                          SizedBox(
                            width: timeColumnWidth,
                            child: Column(
                              children: timeSlots.map((time) => SizedBox(
                                height: hourHeight,
                                child: Text(
                                  time,
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              )).toList(),
                            ),
                          ),

                          // B. THE SCHEDULE STACK (Where the magic happens)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Calculate width of one day column
                                final double dayWidth = constraints.maxWidth / 6; 

                                return SizedBox(
                                  height: hourHeight * timeSlots.length,
                                  child: Stack(
                                    children: [
                                      // 1. Draw Background Lines
                                      for (var i = 0; i < timeSlots.length; i++)
                                        Positioned(
                                          top: i * hourHeight,
                                          left: 0, right: 0,
                                          child: Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                                        ),
                                      for (var i = 0; i <= 6; i++)
                                        Positioned(
                                          left: i * dayWidth,
                                          top: 0, bottom: 0,
                                          child: VerticalDivider(color: Colors.white.withValues(alpha: 0.2), width: 1),
                                        ),

                                      // 2. THE CLASSES
                                      ...schedule.map((classBlock) {
                                        final dayIndex = days.indexOf(classBlock.day);
                                        if (dayIndex == -1) return const SizedBox.shrink();
                                        
                                        return _buildClassCard(
                                          context,
                                          ref,
                                          classBlock,
                                          dayIndex,
                                          dayWidth,
                                          hourHeight,
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Function to calculate size and position
  Widget _buildClassCard(BuildContext context, WidgetRef ref, ClassBlock classBlock, int dayIndex, double width, double hourHeight) {
    return Positioned(
      left: dayIndex * width + 2, // +2 for spacing
      top: (classBlock.startHour - 8) * hourHeight, // Subtract 8 because grid starts at 8 AM
      width: width - 4, // -4 for spacing
      height: (classBlock.duration * hourHeight) - 2,
      child: GestureDetector(
        onTap: () => _showClassDialog(context, ref, classBlock),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Color(classBlock.colorValue).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(2, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                classBlock.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                classBlock.time,
                style: const TextStyle(fontSize: 9, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
