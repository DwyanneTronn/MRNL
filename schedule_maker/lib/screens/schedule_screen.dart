import 'dart:ui';
import 'dart:io';
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
    final timeController = TextEditingController(text: classBlock?.time);
    final dayController = TextEditingController(text: classBlock?.day);
    final locationController = TextEditingController(text: classBlock?.location);
    int selectedColor = classBlock?.colorValue ?? 0xFF64B5F6;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit Class' : 'Add Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Time (e.g. 08:00 AM)'),
                ),
                TextField(
                  controller: dayController,
                  decoration: const InputDecoration(labelText: 'Day (e.g. Mon)'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16),
                const Text('Pick a color:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _colorOption(0xFF64B5F6, selectedColor, (val) => setState(() => selectedColor = val)),
                    _colorOption(0xFFFFB74D, selectedColor, (val) => setState(() => selectedColor = val)),
                    _colorOption(0xFF81C784, selectedColor, (val) => setState(() => selectedColor = val)),
                    _colorOption(0xFF9575CD, selectedColor, (val) => setState(() => selectedColor = val)),
                    _colorOption(0xFFE57373, selectedColor, (val) => setState(() => selectedColor = val)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (isEditing)
              TextButton(
                onPressed: () {
                  ref.read(scheduleProvider.notifier).deleteClass(classBlock.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newClass = ClassBlock(
                  id: isEditing ? classBlock.id : const Uuid().v4(),
                  name: nameController.text,
                  time: timeController.text,
                  day: dayController.text,
                  location: locationController.text,
                  colorValue: selectedColor,
                );
                if (isEditing) {
                  ref.read(scheduleProvider.notifier).updateClass(newClass);
                } else {
                  ref.read(scheduleProvider.notifier).addClass(newClass);
                }
                Navigator.pop(context);
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
    final classes = ref.watch(scheduleProvider);
    final backgroundState = ref.watch(backgroundProvider);

    final String? displayImagePath =
        backgroundState.pendingImagePath ?? backgroundState.savedImagePath;
    final bool hasPendingChanges = backgroundState.pendingImagePath != null;

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Background Image
          Positioned.fill(
            child: displayImagePath != null
                ? (displayImagePath.startsWith('http')
                    ? Image.network(
                        displayImagePath,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(displayImagePath),
                        fit: BoxFit.cover,
                      ))
                : Container(color: Colors.grey),
          ),

          // Layer 2: Blur Effect (Glassmorphism)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),

          // Layer 3: Content
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
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classBlock = classes[index];
                        return GestureDetector(
                          onTap: () => _showClassDialog(context, ref, classBlock),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  classBlock.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(classBlock.colorValue)
                                        .withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    classBlock.time,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  classBlock.day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                if (classBlock.location != null && classBlock.location!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on, size: 12, color: Colors.white70),
                                        const SizedBox(width: 4),
                                        Text(
                                          classBlock.location!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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
    );
  }
}
