import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C18),
        primaryColor: const Color(0xFF00D4FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4FF),
          secondary: Color(0xFF00FF88),
          surface: Color(0xFF0D1526),
          error: Color(0xFFFF4466),
        ),
        fontFamily: 'RobotoMono',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080C18),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF00D4FF),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            fontFamily: 'RobotoMono',
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFB0C4DE), fontFamily: 'RobotoMono'),
          bodySmall: TextStyle(color: Color(0xFF607B96), fontFamily: 'RobotoMono'),
        ),
        dialogBackgroundColor: const Color(0xFF0D1526),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF111D35),
          labelStyle: TextStyle(color: Color(0xFF607B96), fontFamily: 'RobotoMono', fontSize: 12),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1E3A5F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1E3A5F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00D4FF), width: 1.5),
          ),
          hintStyle: TextStyle(color: Color(0xFF3A5472), fontFamily: 'RobotoMono'),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00D4FF),
            textStyle: const TextStyle(fontFamily: 'RobotoMono', letterSpacing: 1.5, fontSize: 12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00D4FF),
          foregroundColor: Color(0xFF080C18),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return const Color(0xFF00FF88);
            return Colors.transparent;
          }),
          side: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        dividerColor: const Color(0xFF1E3A5F),
        popupMenuTheme: const PopupMenuThemeData(
          color: Color(0xFF0D1526),
          textStyle: TextStyle(color: Color(0xFFB0C4DE), fontFamily: 'RobotoMono', fontSize: 13),
        ),
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}