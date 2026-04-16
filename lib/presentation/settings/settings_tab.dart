import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/exports_engine.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/tracker_session.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    final sessionsBox = Hive.box<TrackerSession>('sessions');

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final horizontalPadding = isWide ? 32.0 : 16.0;

    return ListView(
      padding: EdgeInsets.all(horizontalPadding),
      children: [
        const Text(
          'Preferences',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          child: ValueListenableBuilder(
            valueListenable: settingsBox.listenable(keys: ['isDarkMode']),
            builder: (context, Box box, _) {
              final isDark = box.get('isDarkMode', defaultValue: false) as bool;
              return SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: isDark,
                onChanged: (val) {
                  box.put('isDarkMode', val);
                },
              );
            },
          ),
        ),
        Card(
          elevation: 0,
          child: ValueListenableBuilder(
            valueListenable: settingsBox.listenable(
              keys: ['dailyReminder', 'reminderTime'],
            ),
            builder: (context, Box box, _) {
              final isEnabled =
                  box.get('dailyReminder', defaultValue: false) as bool;
              final reminderTimeStr =
                  box.get('reminderTime', defaultValue: '17:00') as String;
              final parts = reminderTimeStr.split(':');
              final timeOfDay = TimeOfDay(
                hour: int.tryParse(parts[0]) ?? 17,
                minute: int.tryParse(parts[1]) ?? 0,
              );

              return Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Study Reminder'),
                    subtitle: const Text('Get notified every day'),
                    secondary: const Icon(Icons.notifications_active_outlined),
                    value: isEnabled,
                    onChanged: (val) async {
                      await NotificationService.toggleDailyReminder(
                        val,
                        timeOfDay,
                      );
                      box.put('dailyReminder', val);
                    },
                  ),
                  if (isEnabled)
                    ListTile(
                      title: const Text('Reminder Time'),
                      subtitle: Text(timeOfDay.format(context)),
                      leading: const Icon(
                        Icons.access_time,
                        color: Colors.teal,
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: timeOfDay,
                        );
                        if (picked != null) {
                          final newTimeStr = '${picked.hour}:${picked.minute}';
                          box.put('reminderTime', newTimeStr);
                          await NotificationService.toggleDailyReminder(
                            true,
                            picked,
                          );
                        }
                      },
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Data Export',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          child: ListTile(
            title: const Text('Export to CSV'),
            subtitle: const Text('Copy to clipboard'),
            leading: const Icon(
              Icons.table_chart_outlined,
              color: Colors.blueGrey,
            ),
            onTap: () async {
              await ExportsEngine.exportToClipboard(
                sessionsBox.values.toList(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('CSV copied!')));
              }
            },
          ),
        ),
        Card(
          elevation: 0,
          child: ListTile(
            title: const Text('Export to PDF'),
            subtitle: const Text('Generate and save PDF doc'),
            leading: const Icon(
              Icons.picture_as_pdf_outlined,
              color: Colors.redAccent,
            ),
            onTap: () async {
              await ExportsEngine.exportToPDF(sessionsBox.values.toList());
            },
          ),
        ),
      ],
    );
  }
}
