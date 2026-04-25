import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';

import 'auth_guard.dart';

class ActividadesScreen extends StatefulWidget {
  final String materia;

  const ActividadesScreen({super.key, required this.materia});

  @override
  State<ActividadesScreen> createState() => _ActividadesScreenState();

}

class _ActividadesScreenState extends State<ActividadesScreen> {
  final supabase = Supabase.instance.client;

  final List<String> actividades = [
    "Actividad Uno",
    "Actividad Dos",
    "Actividad Tres",
    "Actividad Cuatro",
  ];

  // ================= INTERNET =================
  Future<bool> hayInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    sincronizar();
  }

  //  SINCRONIZAR
  Future<void> sincronizar() async {
    final db = DatabaseHelper.instance;
    final user = supabase.auth.currentUser;

    if (await hayInternet()) {
      final pendientes = await db.getNotasNoSync();

      for (var nota in pendientes) {
        await supabase.from('notas').insert({
          'materia': nota['materia'],
          'actividad': nota['actividad'],
          'nota': nota['nota'],
          'user_id': user!.id,
        });

        await db.marcarComoSync(nota['id']);
      }
    }
  }

  //  OBTENER NOTAS
  Future<List<Map<String, dynamic>>> _obtenerNotas() async {
    final db = DatabaseHelper.instance;
    final user = supabase.auth.currentUser;

    try {
      final notasLocales = await db.getNotas();

      if (await hayInternet()) {
        final data = await supabase
            .from('notas')
            .select()
            .eq('materia', widget.materia)
            .eq('user_id', user!.id);

        return List<Map<String, dynamic>>.from(data);
      } else {
        return notasLocales;
      }
    } catch (e) {
      return await db.getNotas();
    }
  }

  // ================= GUARDAR =================
  void _guardarNota(String actividad, {Map<String, dynamic>? notaData}) {
    final controller = TextEditingController(
      text: notaData?['nota']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nota - $actividad"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Ingrese la nota (0 - 5)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = DatabaseHelper.instance;
              final user = supabase.auth.currentUser;

              try {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ingrese una nota")),
                  );
                  return;
                }

                final notaValor = controller.text;

                if (await hayInternet()) {
                  // ONLINE
                  if (notaData == null) {
                    await supabase.from('notas').insert({
                      'materia': widget.materia,
                      'actividad': actividad,
                      'nota': notaValor,
                      'user_id': user!.id,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Guardado en la nube")),
                    );
                  } else {
                    await supabase
                        .from('notas')
                        .update({'nota': notaValor})
                        .eq('id', notaData['id']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Actualizado en la nube")),
                    );
                  }
                } else {
                  // OFFLINE
                  if (notaData == null) {
                    await db.insertNota({
                      'materia': widget.materia,
                      'actividad': actividad,
                      'nota': notaValor,
                      'synced': 0,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Guardado offline")),
                    );
                  } else {
                    await db.updateNota(
                      notaData['id'],
                      notaValor,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Editado offline")),
                    );
                  }
                }

                Navigator.pop(context);
                setState(() {});
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // ================= ELIMINAR =================
  void _eliminarNota(dynamic id) async {
    final db = DatabaseHelper.instance;

    if (await hayInternet()) {
      await supabase.from('notas').delete().eq('id', id);
    } else {
      await db.deleteNota(id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nota eliminada")),
    );

    setState(() {});
  }

  // ================= PROMEDIO =================
  double calcularPromedio(List<Map<String, dynamic>> notas) {
    double total = 0;

    for (var actividad in actividades) {
      final nota = notas.firstWhere(
            (n) => n['actividad'] == actividad,
        orElse: () => {},
      );

      if (nota.isNotEmpty) {
        total += double.tryParse(nota['nota'].toString()) ?? 0;
      }
    }

    return total / 4;
  }

  //  UI
  @override
  Widget build(BuildContext context) {

    if (!AuthGuard.verificar(context)) {
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materia),
      ),
      body: FutureBuilder(
        future: _obtenerNotas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notas = snapshot.data!;
          final promedio = calcularPromedio(notas);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: actividades.map((actividad) {
                    final nota = notas.firstWhere(
                          (n) => n['actividad'] == actividad,
                      orElse: () => {},
                    );

                    final existe = nota.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(actividad),
                        subtitle: Text(
                          existe ? "Nota: ${nota['nota']}" : "Sin nota",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(existe ? Icons.edit : Icons.add),
                              onPressed: () {
                                _guardarNota(
                                  actividad,
                                  notaData: existe ? nota : null,
                                );
                              },
                            ),
                            if (existe)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _eliminarNota(nota['id']),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              //  PROMEDIO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: promedio < 3
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: promedio < 3 ? Colors.red : Colors.green,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Promedio Final",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      promedio.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:
                        promedio < 3 ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      promedio >= 3 ? "Aprobado " : "Reprobado ",
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}