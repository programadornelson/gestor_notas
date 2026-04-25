# Gestor de Notas Académicas

Aplicación móvil desarrollada en Flutter para la gestión de notas académicas con autenticación segura, almacenamiento remoto y persistencia local offline.

---

##  Características principales

*  Registro e inicio de sesión con Supabase  
*  Persistencia de sesión segura (Secure Storage)  
*  CRUD de notas académicas  
*  Gestión por materias  
*  Promedio automático de notas  
*  Modo offline con SQLite  
*  Sincronización automática al recuperar internet  
*  Uso de Provider (estado global)  
*  Cámara para foto de perfil  
*  Geolocalización bajo demanda  
* Control de permisos Android modernos

---

##  Tecnologías utilizadas

- Flutter
- Dart
- Supabase
- SQLite
- Provider
- Secure Storage
- Image Picker
- Geolocator

---

##  Pantallas principales

- Login
- Registro
- HomeScreen
- Materias
- Actividades / CRUD Notas

---

##  Seguridad implementada

- Autenticación con Supabase Auth
- Persistencia segura con token
- Protección de rutas
- Cierre de sesión seguro

---

##  Permisos usados

- Cámara (foto perfil)
- Ubicación GPS (solo cuando usuario la solicita)

---

##  Instalación

```bash
git clone https://github.com/programadornelson/gestor_notas.git
cd gestor_notas
flutter pub get
flutter run

---

##  Autor
Nelson Adrian Ramirez
