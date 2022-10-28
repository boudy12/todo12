import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo/shared/cubit/states.dart';
import 'package:sqflite/sqflite.dart';


class TodoCubit extends Cubit<TodoStates>{

  late Database db;

  bool isBottomSheetShown = false;
  IconData floatingIcon = Icons.edit;
  int currentIndex = 0;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];

  TodoCubit() : super (InitialState());

  static TodoCubit get(context) => BlocProvider.of(context);



  void changeBottomSheet({
  required bool isShown,
  required IconData icon,
}){
    isBottomSheetShown = isShown;
    floatingIcon = icon;
    emit(BottomSheetChangeState());
  }

  void changeIndex(int index){
    currentIndex = index;
    emit(BottomNavBarChangeState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) {
        print('Database Created');
        db.execute(
            "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)")
            .then((value) => print('Table Created'))
            .catchError((error) =>
            print("Error when creating database -${error.toString()}"));
      },
      onOpen: (db) {
        print('Database Opened');
        getTasks(db);
      },
    ).then((value) {
      db = value;
      emit(CreateDatabaseState());
    });
  }

  setTask({
    required title,
    required date,
    required time,
  }) async
  {
    await db.transaction((txn) async {
      txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      ).then((value)
    {
          emit(SetTasksState());

          getTasks(db);
        })
        .catchError((error) {
          print('Error when inserting new record ${error.toString()}');
        });
    });
  }

  void getTasks(db) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(LoadingState());
    db.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element)
      {
        if(element['status'] == 'new') {
          newTasks.add(element);
        } else if(element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(GetTasksState());
    });
  }

  void updateStatus({
    required String status,
    required int id,
  }) async
  {
    db.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        [status, id],
    ).then((value) {
      getTasks(db);
      emit(UpdateStatusState());
    });
  }

  void deleteTask({
    required int id,
  }) async
  {
    db.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id]
    ).then((value) {
      getTasks(db);
      emit(DeleteTaskState());
    });
  }

}