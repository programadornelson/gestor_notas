import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import 'MateriasScreen.dart';
import 'LoginScreen.dart';
import 'session_service.dart';
import 'providers/app_provider.dart';
import 'auth_guard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  File? imagenPerfil;

  String ubicacion =
      "Ubicación no obtenida";

  //  TOMAR FOTO
  Future<void> tomarFoto() async {
    final permiso =
    await Permission.camera.request();

    if (permiso.isGranted) {
      final picker = ImagePicker();

      final foto =
      await picker.pickImage(
        source: ImageSource.camera,
      );

      if (foto != null) {
        setState(() {
          imagenPerfil =
              File(foto.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Permiso de cámara denegado",
          ),
        ),
      );
    }
  }

  //  OBTENER UBICACIÓN
  Future<void>
  obtenerUbicacion() async {

    final permiso =
    await Permission.location
        .request();

    if (permiso.isGranted) {
      Position posicion =
      await Geolocator
          .getCurrentPosition(
        desiredAccuracy:
        LocationAccuracy.high,
      );

      setState(() {
        ubicacion =
        "Lat: ${posicion.latitude}\nLng: ${posicion.longitude}";
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Permiso de ubicación denegado",
          ),
        ),
      );
    }
  }

  //  LOGOUT
  Future<void> logout() async {

    Provider.of<AppProvider>(
      context,
      listen: false,
    ).cerrarSesion();

    await Supabase.instance.client
        .auth
        .signOut();

    await SessionService
        .cerrarSesion();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!AuthGuard.verificar(
        context)) {
      return const SizedBox();
    }

    final app =
    Provider.of<AppProvider>(
        context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio"),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
            const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body:
      FutureBuilder<
          List<
              Map<String,
                  dynamic>>>(
        future: _obtenerNotas(),
        builder:
            (context, snapshot) {

          if (snapshot
              .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final notas =
              snapshot.data ?? [];

          return Padding(
            padding:
            const EdgeInsets
                .all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [

                //  FOTO PERFIL
                Center(
                  child:
                  CircleAvatar(
                    radius: 45,
                    backgroundImage:
                    imagenPerfil !=
                        null
                        ? FileImage(
                        imagenPerfil!)
                        : null,
                    child:
                    imagenPerfil ==
                        null
                        ? const Icon(
                      Icons
                          .person,
                      size:
                      50,
                    )
                        : null,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Center(
                  child: ElevatedButton(
                    onPressed:
                    tomarFoto,
                    child: const Text(
                      "Tomar Foto",
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                //  USUARIO
                Text(
                  "Usuario: ${app.correo}",
                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                const SizedBox(
                    height: 15),

                //  UBICACIÓN
                ElevatedButton(
                  onPressed:
                  obtenerUbicacion,
                  child: const Text(
                    "Obtener Ubicación",
                  ),
                ),

                const SizedBox(
                    height: 8),

                Text(ubicacion),

                const SizedBox(
                    height: 20),

                const Text(
                  "Resumen de Notas",
                  style:
                  TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),

                const SizedBox(
                    height: 10),

                // 📚 NOTAS
                Expanded(
                  child: notas
                      .isEmpty
                      ? const Center(
                    child: Text(
                      "No hay notas registradas",
                    ),
                  )
                      : ListView.builder(
                    itemCount:
                    notas
                        .length,
                    itemBuilder:
                        (context,
                        index) {
                      final nota =
                      notas[
                      index];

                      return Card(
                        child:
                        ListTile(
                          leading:
                          const Icon(
                            Icons
                                .book,
                          ),
                          title:
                          Text(
                            nota[
                            'materia'],
                          ),
                          subtitle:
                          Text(
                            "${nota['actividad']} - Nota: ${nota['nota']}",
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                    height: 10),

                // 🔘 IR MATERIAS
                SizedBox(
                  width: double
                      .infinity,
                  child:
                  ElevatedButton(
                    onPressed:
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                          const MateriasScreen(),
                        ),
                      );
                    },
                    child:
                    const Text(
                      "Ir a Materias",
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 📥 NOTAS
  Future<
      List<
          Map<String,
              dynamic>>>
  _obtenerNotas() async {

    final supabase =
        Supabase.instance.client;

    final user =
        supabase.auth.currentUser;

    final data =
    await supabase
        .from('notas')
        .select()
        .eq(
      'user_id',
      user!.id,
    );

    return List<
        Map<String,
            dynamic>>.from(data);
  }
}