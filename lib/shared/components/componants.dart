import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:google_fonts/google_fonts.dart';

Widget defaultButton({
  required String text,
  required Function function,
  Color color = Colors.blueAccent,
  double width = double.infinity,
  double raduis = 0.0,
  bool isUpperCase = true,
}) => Container(
  height: 50,
  width: width,
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(raduis),
  ),
  child: MaterialButton(
    onPressed: (){
      function();
    },
    child: Text(
      isUpperCase ? text.toUpperCase() : text,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
  ),
);


Widget defaultFormField({
  required TextEditingController controller,
  required String label,
  required TextInputType inputType,
  required String? Function(String? value) validate,
  required IconData? prefixIcon,
  VoidCallback? onTap,
  IconData? suffixIcon,
  VoidCallback? suffixPressed,
  Function(String)? onSubmit,
  bool isPassword = false,
}) => TextFormField(
  obscureText: isPassword,
  controller: controller,
  decoration: InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    prefixIcon: Icon(prefixIcon),
    suffixIcon: IconButton(
      icon: Icon(suffixIcon),
      onPressed: suffixPressed,
    ),
  ), keyboardType: inputType,
  onFieldSubmitted: onSubmit,
  onTap: onTap,
  validator: validate,
);

Widget buildTaskItem(Map item, context) => Dismissible(
  key: Key(item['id'].toString()),
  child:   Padding(

    padding: const EdgeInsets.all(20.0),

    child: Row(

      children: [

        CircleAvatar(

          radius: 40,

          backgroundColor: Color.fromRGBO(147, 202, 237, 1),

          child: Text(

            "${item['time']}",

            style: TextStyle(

              color: Colors.white,

              fontWeight: FontWeight.w500,

            ),

          ),

        ),

        const SizedBox(

          width: 18,

        ),

        Expanded(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                "${item['title']}",

                style: TextStyle(

                  fontWeight: FontWeight.bold,

                  fontSize: 20,

                ),

              ),

              Text(

                "${item['date']}",

                style: TextStyle(

                  color: Colors.grey,

                ),

              ),

            ],

          ),

        ),

        const SizedBox(

          width: 18,

        ),

        IconButton(onPressed: ()

        {

          TodoCubit.get(context).updateStatus(

              status: 'done',

              id: item['id'],

          );

        },

            icon: const Icon(

              Icons.check_circle,

              color: Color.fromRGBO(28, 147, 79, 0.7019607843137254),

            ),

        ),

        IconButton(onPressed: (){

          TodoCubit.get(context).updateStatus(

              status: 'archived',

              id: item['id']

          );

        },

          icon: const Icon(

            Icons.archive_rounded,

            color: Color.fromRGBO(128, 109, 109, 0.8),

          ),

        )

      ],

    ),

  ),
  onDismissed: (direction){
    TodoCubit.get(context).deleteTask(id: item['id']);
  },
);

Widget taskBuild({
      required List<Map> tasks
}) => ConditionalBuilder(
    condition: tasks.isNotEmpty,
    builder: (BuildContext context) => ListView.separated(
      itemBuilder: (context, index) {
        return buildTaskItem(tasks[index], context);
      },
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 20),
        child: Container(
          height: 1,
          width: double.infinity,
          color: Colors.grey,
        ),
      ),
      itemCount: tasks.length,
    ),
    fallback: (BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 120),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              'there is no tasks yet',
              style: GoogleFonts.comicNeue(
                textStyle: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    )
);
