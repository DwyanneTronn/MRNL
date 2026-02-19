import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Setup the Time Range (8 AM to 8 PM based on your image)
    final timeSlots = [
      '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', 
      '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', 
      '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']; // Added Saturday

    // 2. Configuration for the layout
    const double hourHeight = 60.0; // Every hour is 60 pixels tall
    const double timeColumnWidth = 60.0;

    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
              fit: BoxFit.cover,
            ),
          ),

          // LAYER 2: Glass Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.2)),
            ),
          ),

          // LAYER 3: The Schedule Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  const Text(
                    'My Schedule',
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                    ),
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
                                          child: Divider(color: Colors.white.withOpacity(0.2), height: 1),
                                        ),
                                      for (var i = 0; i <= 6; i++)
                                        Positioned(
                                          left: i * dayWidth,
                                          top: 0, bottom: 0,
                                          child: VerticalDivider(color: Colors.white.withOpacity(0.2), width: 1),
                                        ),

                                      // 2. THE CLASSES (Data from your image)
                                      
                                      // MONDAY & THURSDAY: PHILO 13 (9:30 - 11:00)
                                      _buildClassCard('PHILO 13', '9:30-11:00', 0, 9.5, 1.5, Colors.lightGreen, dayWidth, hourHeight), // Mon
                                      _buildClassCard('PHILO 13', '9:30-11:00', 3, 9.5, 1.5, Colors.lightGreen, dayWidth, hourHeight), // Thu

                                      // MONDAY & THURSDAY: MSYS 51 (3:30 - 5:00)
                                      _buildClassCard('MSYS 51', '3:30-5:00', 0, 15.5, 1.5, Colors.purple.shade300, dayWidth, hourHeight),
                                      _buildClassCard('MSYS 51', '3:30-5:00', 3, 15.5, 1.5, Colors.purple.shade300, dayWidth, hourHeight),

                                      // MONDAY & THURSDAY: SocSc 13 (6:30 - 8:00)
                                      _buildClassCard('SocSc 13', '6:30-8:00', 0, 18.5, 1.5, Colors.orange.shade300, dayWidth, hourHeight),
                                      _buildClassCard('SocSc 13', '6:30-8:00', 3, 18.5, 1.5, Colors.orange.shade300, dayWidth, hourHeight),

                                      // TUESDAY & FRIDAY: MSYS 42 (12:30 - 2:00)
                                      _buildClassCard('MSYS 42', '12:30-2:00', 1, 12.5, 1.5, Colors.amber.shade300, dayWidth, hourHeight),
                                      _buildClassCard('MSYS 42', '12:30-2:00', 4, 12.5, 1.5, Colors.amber.shade300, dayWidth, hourHeight),

                                      // TUESDAY & FRIDAY: ITMGT 46 (3:30 - 5:00)
                                      _buildClassCard('ITMGT 46', '3:30-5:00', 1, 15.5, 1.5, Colors.green.shade200, dayWidth, hourHeight),
                                      _buildClassCard('ITMGT 46', '3:30-5:00', 4, 15.5, 1.5, Colors.green.shade200, dayWidth, hourHeight),

                                      // WEDNESDAY: NSTP 12 (8:00 - 12:00)
                                      _buildClassCard('NSTP 12', '8:00-12:00', 2, 8.0, 4.0, Colors.pink.shade100, dayWidth, hourHeight),

                                      // FRIDAY: ISCS 30.13 (11:00 - 12:00)
                                      _buildClassCard('ISCS 30.13', '11:00-12:00', 4, 11.0, 1.0, Colors.red.shade300, dayWidth, hourHeight),

                                      // SATURDAY: CSCI 111 (11:00 - 2:00)
                                      _buildClassCard('CSCI 111', '11:00-2:00', 5, 11.0, 3.0, Colors.teal.shade300, dayWidth, hourHeight),
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
  Widget _buildClassCard(String title, String time, int dayIndex, double startHour, double duration, Color color, double width, double hourHeight) {
    return Positioned(
      left: dayIndex * width + 2, // +2 for spacing
      top: (startHour - 8) * hourHeight, // Subtract 8 because grid starts at 8 AM
      width: width - 4, // -4 for spacing
      height: (duration * hourHeight) - 2,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
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
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 9, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}