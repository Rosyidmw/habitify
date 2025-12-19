class Habit {
  final int? id;
  final String title;
  final bool isCompleted;
  final int targetMinutes;

  final DateTime createdAt;

  Habit({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.targetMinutes = 0,
    required this.createdAt,
  });

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      isCompleted: map['is_completed'] == 1,
      targetMinutes: map['target_minutes'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'target_minutes': targetMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Habit copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? targetMinutes,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
