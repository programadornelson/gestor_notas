
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'HomeScreen.dart';
import 'RegistroScreen.dart';
import 'session_service.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Ingrese correo";
    }

    if (!value.endsWith("@gmail.com")) {
      return "Correo inválido";
    }

    return null;
  }

  String? validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Ingrese contraseña";
    }

    if (value.length < 6) {
      return "Mínimo 6 caracteres";
    }

    return null;
  }

  Future<void> _login() async {
    final supabase = Supabase.instance.client;

    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child:
            CircularProgressIndicator(),
          ),
        );

        final response =
        await supabase.auth
            .signInWithPassword(
          email: _emailController.text.trim(),
          password:
          _passwordController.text.trim(),
        );

        final token =
            response.session?.accessToken;

        if (token != null) {
          await SessionService
              .guardarToken(token);
        }

        if (!mounted) return;

        Navigator.pop(context);

//  GUARDAR USUARIO EN PROVIDER
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).iniciarSesion(
          _emailController.text.trim(),
        );

// IR A HOME
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } catch (e) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
            Text("Error: $e"),
          ),
        );
      }
    }
  }

  void _irRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const RegistroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              TextFormField(
                controller:
                _emailController,
                validator:
                validarEmail,
                decoration:
                const InputDecoration(
                  labelText:
                  "Correo Gmail",
                ),
              ),
              const SizedBox(
                  height: 20),
              TextFormField(
                controller:
                _passwordController,
                obscureText: true,
                validator:
                validarPassword,
                decoration:
                const InputDecoration(
                  labelText:
                  "Contraseña",
                ),
              ),
              const SizedBox(
                  height: 30),
              ElevatedButton(
                onPressed: _login,
                child: const Text(
                    "Ingresar"),
              ),
              TextButton(
                onPressed:
                _irRegistro,
                child: const Text(
                    "Registrarse"),
              )
            ],
          ),
        ),
      ),
    );
  }
}