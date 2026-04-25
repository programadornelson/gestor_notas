import 'package:gestor_notas/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestor_notas/ActividadesScreen.dart';

import 'auth_guard.dart';

class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AuthGuard.verificar(context)) {
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Materias"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async
            {
              final supabase = Supabase.instance.client;

              // Confirmación antes de salir
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Cerrar sesión"),
                  content: const Text("¿Seguro que deseas salir?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Salir"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await supabase.auth.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: ListView(
        children: [

          ListTile(
            title: const Text("Bases de Datos"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActividadesScreen(materia: "Bases de Datos"),
                ),
              );
            },
          ),

          ListTile(
            title: const Text("Lógica de Programación"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActividadesScreen(materia: "Lógica de Programación"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}