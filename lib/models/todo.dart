class Todo {
  final int id;
  final String title;
  final bool completed;
  final String userId;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    completed: json['completed'],
    userId: json['user_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Todo copyWith({
    int? id,
    String? title,
    bool? completed,
    String? userId,
    DateTime? createdAt,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );
}
