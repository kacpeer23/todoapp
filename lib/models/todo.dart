class Todo {
  final int? id;
  final String? title;
  final int? isDone;
  final int? taskID;

  Todo({this.id, this.title, this.isDone, this.taskID});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }
}
