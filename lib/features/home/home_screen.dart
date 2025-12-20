import 'package:flutter/material.dart';
import 'package:habitify/features/settings/settings_screen.dart';
import 'package:habitify/features/stats/stats_screen.dart';
import 'package:habitify/models/habit_model.dart';
import 'package:habitify/providers/habit_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _habitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<HabitProvider>(context, listen: false).loadHabits(),
    );
  }

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  void _showAddHabitSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mulai Kebiasaan Baru',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _habitController,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: Minum air 2 liter...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: .none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_habitController.text.isNotEmpty) {
                    context.read<HabitProvider>().addHabit(
                      _habitController.text,
                    );
                    _habitController.clear();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Simpan Habit'),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat(
      'EEEE, d MMM',
      'id_ID',
    ).format(DateTime.now());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hari Ini',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              todayDate,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsScreen()),
              );
            },
            icon: Icon(Icons.bar_chart_rounded),
            tooltip: "Lihat Statistik",
          ),
          SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context),
        label: Text('Habit Baru'),
        icon: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_rtl_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada habit hari ini',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.habits.length,
            itemBuilder: (context, index) {
              final habit = provider.habits[index];
              return _buildHabitCard(context, habit, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    Habit habit,
    HabitProvider provider,
  ) {
    return Dismissible(
      key: Key(habit.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final deletedHabit = habit;

        provider.deleteHabit(habit.id!);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1F2937),
            elevation: 4,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 180,
              left: 20,
              right: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 4),

            content: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Habit dihapus',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        deletedHabit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'URUNGKAN',
              textColor: const Color(0xFF818CF8),
              onPressed: () {
                provider.restoreHabit(deletedHabit);
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_forever_rounded,
          color: Colors.red[700],
          size: 28,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: habit.isCompleted
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: habit.isCompleted,
              activeColor: const Color(0xFF10B981),
              shape: const CircleBorder(),
              onChanged: (value) => provider.toggleHabit(habit),
            ),
          ),
          title: Text(
            habit.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: habit.targetMinutes > 0
              ? Text(
                  '${habit.targetMinutes} menit',
                  style: const TextStyle(fontSize: 12),
                )
              : null,
        ),
      ),
    );
  }
}
