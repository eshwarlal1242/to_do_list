
class TaskModel {
  int id;
  String task;

  TaskModel({required this.id, required this.task});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      task: json['task'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
    };
  }
}
