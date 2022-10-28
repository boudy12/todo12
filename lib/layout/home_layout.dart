import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo/shared/components/componants.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';
import 'package:intl/intl.dart';

class HomeLayout extends StatelessWidget {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();


  HomeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TodoCubit()..createDatabase(),
      child: BlocConsumer<TodoCubit, TodoStates>(
        listener:(context, state) {
          if(state is SetTasksState){
            Navigator.pop(context);
          }
        },
        builder:(context, state) {
          TodoCubit cubit = TodoCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: const Text('Todo'),
            ),
            body: ConditionalBuilder(
              condition: state is! LoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                if (cubit.isBottomSheetShown)
                {
                  if (formKey.currentState!.validate())
                  {
                    cubit.setTask(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);
                  }
                }
                else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                      padding: const EdgeInsets.all(15.0),
                      color: const Color.fromRGBO(147, 202, 237, 0.1),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              label: "Title",
                              inputType: TextInputType.text,
                              validate: (String? context) {
                                if (context!.isEmpty) {
                                  return 'title cannot be empty';
                                }
                                return null;
                              },
                              prefixIcon: Icons.title,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            defaultFormField(
                              controller: timeController,
                              label: "Time",
                              inputType: TextInputType.datetime,
                              validate: (String? context) {
                                if (context!.isEmpty) {
                                  return 'time cannot be empty';
                                }
                                return null;
                              },
                              prefixIcon: Icons.watch_later_outlined,
                              onTap: () {
                                showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now())
                                    .then((value) {
                                  timeController.text =
                                      value!.format(context).toString();
                                  print(value.format(context));
                                });
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            defaultFormField(
                              controller: dateController,
                              label: "Date",
                              inputType: TextInputType.datetime,
                              validate: (String? context) {
                                if (context!.isEmpty) {
                                  return 'date cannot be empty';
                                }
                                return null;
                              },
                              prefixIcon: Icons.calendar_today,
                              onTap: () {
                                showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2022-10-10'))
                                    .then((value) {
                                  dateController.text =
                                      DateFormat.yMMMd().format(value!);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    elevation: 25,
                  )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheet(isShown: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheet(isShown: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.floatingIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 25,
              fixedColor: Colors.red[900],
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: 'archive',
                ),
              ],
            ),
          );
      }
      ),
    );
  }

}
