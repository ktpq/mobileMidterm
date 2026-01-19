class Todo {
  final String title;
  final bool status;

  Todo({required this.title, this.status = false});
  Map<String, dynamic> toMap() {
    return {'title': title, 'status': status};
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      title:
          map['title'] ??
          '', // ดึงค่าจาก key 'title' (ถ้าว่างให้เป็น String ว่าง)
      status:
          map['status'] ??
          false, // ดึงค่าจาก key 'status' (ถ้าว่างให้เป็น false)
    );
  }
}
