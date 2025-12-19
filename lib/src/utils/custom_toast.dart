import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Fluttertoast.showToast(
      msg: "✓ $title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Color(0xFF2E7D32), // Verde oscuro más elegante
      textColor: Colors.white,
      fontSize: 15.0,
      webBgColor: "linear-gradient(to right, #2E7D32, #43A047)",
      webPosition: "center",
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    Fluttertoast.showToast(
      msg: "✕ $title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Color(0xFFC62828), // Rojo oscuro más elegante
      textColor: Colors.white,
      fontSize: 15.0,
      webBgColor: "linear-gradient(to right, #C62828, #E53935)",
      webPosition: "center",
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Fluttertoast.showToast(
      msg: "⚠ $title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Color(0xFFEF6C00), // Naranja oscuro más elegante
      textColor: Colors.white,
      fontSize: 15.0,
      webBgColor: "linear-gradient(to right, #EF6C00, #F57C00)",
      webPosition: "center",
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Fluttertoast.showToast(
      msg: "ℹ $title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Color(0xFF1565C0), // Azul oscuro más elegante
      textColor: Colors.white,
      fontSize: 15.0,
      webBgColor: "linear-gradient(to right, #1565C0, #1976D2)",
      webPosition: "center",
    );
  }

  static void showOffline({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    Fluttertoast.showToast(
      msg: "⊗ $title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Color(0xFF424242), // Gris oscuro más elegante
      textColor: Colors.white,
      fontSize: 15.0,
      webBgColor: "linear-gradient(to right, #424242, #616161)",
      webPosition: "center",
    );
  }
}
