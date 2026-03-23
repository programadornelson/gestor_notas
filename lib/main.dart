import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gestor_notas/LoginScreen.dart';
import 'package:gestor_notas/LoginScreen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vvqqrphhpvqueoguuqwj.supabase.co',
    anonKey: 'sb_publishable_nmQ3HivrkG3cCBw3Sy5Eyw_z4AWv89e',
  );
  runApp(const MyApp());
}

// APP PRINCIPAL
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}