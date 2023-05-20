class Task {
  late int id;
  late int key;
  late String text;
  late int priority;

  Task({
    required this.id,
    required this.key,
    required this.text,
    required this.priority,
  });

  // mapに変換する
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'key': key,
      'text': text,
      'priority': priority,
    };
  }
}
