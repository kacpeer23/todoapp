import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/database_helper.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/models/todo.dart';
import 'package:todoapp/widgets.dart';

class TaskPage extends StatefulWidget {
  final Task? task;

  TaskPage({@required this.task});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  DatabaseHelper _dbHelper = DatabaseHelper();
  int _taskID = 1;
  String _taskTitle = "";
  String _taskDescription = "123";
  FocusNode? _titleFocus;
  FocusNode? _descriptionFocus;
  FocusNode? _todoFocus;
  bool _contentVisible = false;
  @override
  void initState() {
    if (widget.task != null) {
      _taskTitle = widget.task!.title;
      // _taskDescription = widget.task!.description! - jak to dam to wywala błąd z nullem
      _taskID = widget.task!.id!;
      _contentVisible = true;
    }
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24.0,
                      bottom: 12.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage('images/back_arrow_icon.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _titleFocus,
                            onSubmitted: (value) async {
                              if (value != '') {
                                if (widget.task == null) {
                                  DatabaseHelper _dbHelper = DatabaseHelper();
                                  Task _newTask = Task(
                                    title: value,
                                  );
                                  _taskID =
                                      (await _dbHelper.insertTask(_newTask))!;
                                  print('New task id = $_taskID');
                                  setState(() {});
                                  print('new task has been created');
                                } else {
                                  _dbHelper.updateTaskTitle(_taskID, value);
                                  print('Task updated');
                                }
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter task title...',
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF211551),
                            ),
                            controller: TextEditingController()
                              ..text = _taskTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 12.0,
                      ),
                      child: TextField(
                        focusNode: _descriptionFocus,
                        onSubmitted: (value) async {
                          if (value != '') {
                            if (_taskID != 0) {
                              await _dbHelper.updateTaskDescription(
                                  _taskID, value);
                              _taskDescription = value;
                            }
                          }
                          _todoFocus?.requestFocus();
                        },
                        controller: TextEditingController()
                          ..text = _taskDescription,
                        decoration: InputDecoration(
                          hintText: 'Enter description for the task...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: FutureBuilder(
                      future: _dbHelper.getTodo(_taskID),
                      builder: (context, AsyncSnapshot<List<Todo>> snapshot) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    if (snapshot.data![index].isDone == 0) {
                                      await _dbHelper.updateTodoDone(
                                          snapshot.data![index].id!,
                                          1); //nie działa, nie zmienia stanu
                                    } else {
                                      await _dbHelper.updateTodoDone(
                                          snapshot.data![index].id!,
                                          0); //nie działa, nie zmienia stanu
                                    }
                                    setState(() {});
                                  },
                                  child: TodoWidget(
                                    text: snapshot.data?[index].title,
                                    isDone: snapshot.data?[index].isDone == 0
                                        ? false
                                        : true,
                                  ),
                                );
                              }),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Container(
                            height: 20.0,
                            width: 20.0,
                            margin: EdgeInsets.only(right: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: Color(0xFF86829D),
                                width: 1.5,
                              ),
                            ),
                            child: Image(
                              image: AssetImage(
                                'images/check_icon.png',
                              ),
                            ),
                          ),
                          Expanded(
                              child: TextField(
                            focusNode: _todoFocus,
                            onSubmitted: (value) async {
                              if (value != '') {
                                if (widget.task != null) {
                                  DatabaseHelper _dbHelper = DatabaseHelper();
                                  Todo _newTodo = Todo(
                                    title: value,
                                    isDone: 0,
                                    taskID: _taskID,
                                  );
                                  await _dbHelper.insertTodo(_newTodo);
                                  setState(() {});
                                  print('Creating new todo');
                                  _todoFocus?.requestFocus();
                                }
                              }
                            },
                            decoration: InputDecoration(
                                hintText: "Enter todo item...",
                                border: InputBorder.none),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: _contentVisible,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if (_taskID != 0) {
                        await _dbHelper.deleteTask(_taskID);
                        Navigator.pop(context);
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => TaskPage(
                      //       task: null,
                      //     ),
                      //   ),
                      // );
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFFE3577),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image(
                        image: AssetImage('images/delete_icon.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
