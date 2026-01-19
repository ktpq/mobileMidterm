import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ผูกกับ input
  final inputController = TextEditingController();
  final List<Todo> _todoList = [];

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันโหลดข้อมูลทันทีที่สร้าง Widget
    _loadData();
  }

  // ฟังก์ชันดึงข้อมูลจาก SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // ดึง List ของ String ออกมา (ถ้าไม่มีให้เป็น null)
    List<String>? jsonList = prefs.getStringList('todo_data');

    if (jsonList != null) {
      setState(() {
        // แปลงจาก List<String> JSON กลับมาเป็น List<Todo>
        // โดยใช้ map และ Todo.fromMap ที่เราเตรียมไว้ใน Model
        _todoList.clear();
        _todoList.addAll(
          jsonList.map((item) => Todo.fromMap(jsonDecode(item))).toList(),
        );
      });
    }
  }

  void _savePref() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataToSave = _todoList
        .map((todo) => jsonEncode(todo.toMap()))
        .toList();
    await prefs.setStringList("data", dataToSave);
  }

  void _addTodo() {
    if (inputController.text.isNotEmpty) {
      setState(() {
        _todoList.add(Todo(title: inputController.text));
        inputController.clear();
      });
      debugPrint("$_todoList");
      _savePref();
    }
  }

  void _showEditModal(int index) {
    final editController = TextEditingController(text: _todoList[index].title);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Task index = $index",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: editController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey),
                    ),

                    hintText: "Enter your task",
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _todoList[index] = Todo(
                        title: editController.text,
                        status: _todoList[index].status,
                      );
                    });
                    _savePref();
                    Navigator.pop(dialogContext);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          // Layout นอกสุด
          child: Column(
            children: [
              // top bar
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    final item = _todoList[index];

                    // ปรับการแสดงผลให้สวยขึ้นด้วย ListTile หรือ Container
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(),

                      // Row ใหญ่สุด
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: item.status,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _todoList[index] = Todo(
                                      title: item.title,
                                      status: newValue!,
                                    );
                                  });
                                },
                              ),
                              Text(
                                "${item.title}",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showEditModal(index);
                                },
                                child: Text("Edit"),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _todoList.removeAt(index);
                                    _savePref();
                                  });
                                },
                                child: Text("Delete"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),

                        hintText: "Enter your task",
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: CircleBorder(),
                      fixedSize: const Size(60, 60),
                    ),
                    onPressed: _addTodo,
                    child: Text(
                      "+",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(Icons.menu, size: 30, color: Colors.grey),
          SizedBox(width: 15),
          Icon(Icons.shopping_basket_outlined, size: 30, color: Colors.grey),
        ],
      ),
      Text(
        "ALL TASKS",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      Row(
        children: [
          Icon(Icons.book_outlined, size: 30, color: Colors.grey),
          SizedBox(width: 15),
          Icon(Icons.more_outlined, size: 30, color: Colors.grey),
        ],
      ),
    ],
  );
}
