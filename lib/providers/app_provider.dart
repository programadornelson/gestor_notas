import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {

  String correo = "";
  bool logueado = false;

  // LOGIN
  void iniciarSesion(String email) {
    correo = email;
    logueado = true;
    notifyListeners();
  }

  // LOGOUT
  void cerrarSesion() {
    correo = "";
    logueado = false;
    notifyListeners();
  }
}