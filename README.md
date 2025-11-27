<!-- Badges -->
[![Flutter](https://img.shields.io/badge/Flutter-3.9-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)

# SafeMap

> Aplicación móvil Flutter para reportar y visualizar incidentes en la ciudad. Simple, rápida y pensada para uso ciudadano.

![SafeMap Logo](assets/images/logo.png)

---

## 🎯 Qué es

SafeMap permite a los ciudadanos crear reportes con fotos y vídeo, elegir la ubicación en un mapa (respetando los límites municipales), y recibir notificaciones relacionadas con sus reportes. Está construido con Flutter y Firebase, utilizando Cloudinary para almacenar multimedia.

## ✨ Características principales

- Crear reportes con título, descripción, categoría y evidencias (foto/video)
- Selección de ubicación mediante mapa con validación por polígono GeoJSON (no se puede elegir fuera del municipio)
- Visualización de reportes y reproducción de evidencias multimedia
- Panel de notificaciones por usuario y a nivel de ciudad
- Preferencias de cuenta (foto, barrio, notificaciones push)

## 🧭 Tecnologías y librerías

- Flutter (UI)
- Dart (lenguaje)
- Firebase: Auth, Firestore
- Cloudinary (almacenamiento de imágenes y vídeos)
- flutter_map + latlong2 (mapas)
- image_picker (captura y selección de multimedia)
- geolocator (ubicación del dispositivo)
- provider (gestión de estado)
- video_player (reproducción de vídeo)
- flutter_launcher_icons (generar iconos de la app)

Dependencias principales (ver `pubspec.yaml`) incluyen:

```
google_fonts
image_picker
flutter_map
latlong2
geolocator
firebase_core
firebase_auth
cloud_firestore
provider
cloudinary_public
video_player
```

## 🛠️ Requisitos previos

- Flutter instalado (compatible con SDK declarado en `pubspec.yaml`).
- Android SDK / Android Studio (para compilar APK/AAB).
- Java JDK (si compile Android nativo)
- Una cuenta/config de Firebase para `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) si usas backend.

## 🚀 Ejecutar en modo desarrollo

1. Instala dependencias:

```powershell
flutter pub get
```

2. Corre la app en un dispositivo/emulador:

```powershell
flutter run
```

## 📦 Compilar APK / AAB (Android)

- Build debug APK:

```powershell
flutter build apk --debug
```

- Build release APK:

```powershell
flutter build apk --release
```

- Build app bundle (recomendado para Google Play):

```powershell
flutter build appbundle --release
```

> Nota: Asegúrate de tener Android SDK instalado y variables de entorno (`ANDROID_SDK_ROOT`/`ANDROID_HOME`) configuradas. Usa `flutter doctor -v` para verificar.

## 🤝 Contribuir

1. Haz fork del repositorio
2. Crea una rama feature/bugfix
3. Envía un Pull Request con una descripción clara


## 📜 License

This project is provided as-is. Add a license file if you want to set an explicit license (MIT, Apache, etc.).

---

SafeMap Team