import 'package:flutter/material.dart' ;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestor_notas/MateriasScreen.dart';
import 'package:gestor_notas/RegistroScreen.dart';
import 'package:gestor_notas/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //METODO NUEVO

  //HASTA AQUI
  // VALIDAR EMAIL
  String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "El correo es obligatorio";
    }
    if (!value.endsWith("@gmail.com")) {
      return "Debe ser un correo Gmail válido";
    }
    return null;
  }

  // VALIDAR PASSWORD
  String? validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "La contraseña es obligatoria";
    }
    if (value.length < 6) {
      return "Mínimo 6 caracteres";
    }
    return null;
  }

  // LOGIN CON SUPABASE

  Future<void> _login() async {
    final supabase = Supabase.instance.client;

    if (_formKey.currentState!.validate()) {
      try {
        // Mostrar loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Login en Supabase
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Cerrar loading
        Navigator.pop(context);

        // Mensaje éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login exitoso")),
        );
        // 👉 AQUÍ VA LA NAVEGACIÓN (IMPORTANTE)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MateriasScreen(),
          ),
        );

      } catch (e) {
        // Cerrar loading si falla
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
          ),
        );
      }
    }
  }


  // IR A REGISTRO
  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "Notas Académicas",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL
              TextFormField(
                controller: _emailController,
                validator: validarEmail,
                decoration: const InputDecoration(
                  labelText: "Correo Gmail",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: validarPassword,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 30),

              // BOTÓN LOGIN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text("Iniciar Sesión"),
                ),
              ),

              const SizedBox(height: 15),

              // IR A REGISTRO
              TextButton(
                onPressed: _irARegistro,
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
