class History {
  late int id;
  // late double achievement;
  late int done;
  late int number;

  History({
    required this.id,
    // required this.achievement,
    required this.done,
    required this.number,
  });

  // mapに変換する
  Map<String, dynamic> toAllMap() {
    return {
      'id': id,
      // 'achievement': achievement,
      'done': done,
      'number': number,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      // 'achievement': achievement,
      'done': done,
      'number': number,
    };
  }
}
