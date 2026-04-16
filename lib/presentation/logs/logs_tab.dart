import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/utils/mood_mapper.dart';
import '../../data/models/tracker_session.dart';
import '../widgets/session_dialog.dart';

class LogsTab extends StatefulWidget {
  const LogsTab({super.key});

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final sessionBox = Hive.box<TrackerSession>('sessions');
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final horizontalPadding = isWide ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const SessionDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Log Session'),
      ),
      body: ValueListenableBuilder(
        valueListenable: sessionBox.listenable(),
        builder: (context, Box<TrackerSession> box, _) {
          final allSessions = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          final filteredSessions = _searchQuery.isEmpty
              ? allSessions
              : allSessions.where((s) {
                  final query = _searchQuery.toLowerCase();
                  return s.subject.toLowerCase().contains(query) ||
                      s.tags.any((t) => t.toLowerCase().contains(query));
                }).toList();

          return Column(
            children: [
              _SearchBar(
                horizontalPadding: horizontalPadding,
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              Expanded(
                child: filteredSessions.isEmpty
                    ? const Center(
                        child: Text('No study sessions match your search.'),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ).copyWith(bottom: 80),
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          return _SessionCard(
                            session: filteredSessions[index],
                            isWide: isWide,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final double horizontalPadding;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.horizontalPadding, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8.0,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by subject or tag...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TrackerSession session;
  final bool isWide;

  const _SessionCard({required this.session, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isWide ? 24 : 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: isWide ? 28 : 24,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            MoodMapper.getMoodEmoji(session.mood),
            style: TextStyle(fontSize: isWide ? 28 : 24),
          ),
        ),
        title: Text(
          session.subject,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isWide ? 18 : 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${session.hours} hrs • ${DateFormat('MMM dd, yyyy').format(session.date)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              if (session.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    session.tags.join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => SessionDialog(existingSession: session),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => session.delete(),
            ),
          ],
        ),
      ),
    );
  }
}
