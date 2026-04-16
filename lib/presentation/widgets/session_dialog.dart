import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/mood_mapper.dart';
import '../../data/models/tracker_session.dart';

class SessionDialog extends StatefulWidget {
  final TrackerSession? existingSession;

  const SessionDialog({super.key, this.existingSession});

  @override
  State<SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  late TextEditingController _subjectController;
  late TextEditingController _hoursController;
  late TextEditingController _tagsController;
  late double _currentMood;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.existingSession != null;
    _subjectController = TextEditingController(
      text: isEditing ? widget.existingSession!.subject : '',
    );
    _hoursController = TextEditingController(
      text: isEditing ? widget.existingSession!.hours.toString() : '',
    );
    _tagsController = TextEditingController(
      text: isEditing ? widget.existingSession!.tags.join(', ') : '',
    );
    _currentMood = isEditing ? widget.existingSession!.mood.toDouble() : 3.0;
    _selectedDate = isEditing ? widget.existingSession!.date : DateTime.now();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _hoursController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSession() {
    final subject = _subjectController.text.trim();
    final hours = double.tryParse(_hoursController.text.trim());
    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (subject.isEmpty || hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid subject and hours (>0).'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (widget.existingSession != null) {
      // Edit existing
      widget.existingSession!.subject = subject;
      widget.existingSession!.hours = hours;
      widget.existingSession!.mood = _currentMood.toInt();
      widget.existingSession!.tags = tags;
      widget.existingSession!.date = _selectedDate;
      widget.existingSession!.save();
    } else {
      // Create new
      final sessionBox = Hive.box<TrackerSession>('sessions');
      sessionBox.add(
        TrackerSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          subject: subject,
          hours: hours,
          mood: _currentMood.toInt(),
          date: _selectedDate,
          tags: tags,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 450.0 : screenWidth * 0.9;

    return AlertDialog(
      title: Text(
        widget.existingSession != null ? 'Edit Session' : 'New Study Session',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., flutter, dart, studying',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Hours Studied',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Mood: ${MoodMapper.getMoodEmoji(_currentMood.toInt())}',
                style: const TextStyle(fontSize: 32),
              ),
              Slider(
                value: _currentMood,
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (val) => setState(() => _currentMood = val),
              ),
              const SizedBox(height: 16),
              // Date Picker Row
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Session Date',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: _selectDate,
                  child: const Text('Change'),
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saveSession, child: const Text('Save')),
      ],
    );
  }
}
