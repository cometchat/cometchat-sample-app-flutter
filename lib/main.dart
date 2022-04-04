import 'package:flutter/material.dart';
import 'package:sdk_tutorial/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SDK Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Color(0xff131513),
          centerTitle: true,
          textTheme: TextTheme(
              headline6: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0)),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xff131513),
        ),
        inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5.0),
            fillColor: Color(0xffF0F0F0),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                      5.0), //                 <--- border radius here
                ),
                borderSide: BorderSide(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color(0xffDDDDDD))),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                      5.0), //                 <--- border radius here
                ),
                borderSide: BorderSide(
                    width: 0.5,
                    style: BorderStyle.solid,
                    color: Color(0xffDDDDDD))),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                      5.0), //                 <--- border radius here
                ),
                borderSide: BorderSide(
                    width: 1.0,
                    style: BorderStyle.solid,
                    color: Color(0xffDDDDDD))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                      5.0), //                 <--- border radius here
                ),
                borderSide: BorderSide(
                    width: 1.0, style: BorderStyle.solid, color: Colors.black)),
            filled: true,
            hintStyle: TextStyle(color: Color(0xff6B6E6B), fontSize: 14.0)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // first page
      home: const Login(),
    );
  }
}
