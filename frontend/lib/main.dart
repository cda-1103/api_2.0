// frontend/lib/main.dart

// ... (las importaciones y las clases MyApp e InventoryUploadPage van aquí sin cambios) ...
import 'dart:io'; // Necesario para File en móvil/escritorio
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar web
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// Asegúrate de importar el archivo donde definiste headersFromApi
import 'upload_file.dart'; // O el nombre que le hayas puesto

class _InventoryUploadPageState extends State<InventoryUploadPage> {
  // Estado para guardar el archivo seleccionado (usamos PlatformFile)
  PlatformFile? selectedFile;
  // Estado para indicar si está cargando (seleccionando o llamando a la API)
  bool isLoading = false;
  // Estado para guardar las cabeceras recibidas de la API
  List<String> fileHeaders = [];
  // Estado para mostrar mensajes al usuario
  String statusMessage = ' Ningún archivo seleccionado';

  // --- Función llamada al presionar el botón "Seleccionar Archivo" ---
  Future<void> selectFileAndGetHeaders() async {
    // 1. Limpia el estado anterior y muestra 'Cargando...'
    setState(() {
      selectedFile = null;
      fileHeaders = [];
      isLoading = true;
      statusMessage = 'Seleccionando archivo...';
    });

    try {
      // 2. Abre el selector de archivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'], // Solo Excel por ahora
        withData: kIsWeb, // Pide los bytes SOLO si es web
      );

      if (result != null) {
        final file = result.files.first; // Obtiene el PlatformFile
        setState(() {
          selectedFile = file;
          statusMessage = 'Archivo: ${file.name}. Obteniendo cabeceras...';
          // isLoading sigue true
        });

        // 3. Llama a la función del api_service para obtener cabeceras
        final headers = await headersFromApi(file); // Llama a tu función

        // 4. Si tiene éxito, guarda las cabeceras y actualiza el mensaje
        setState(() {
          fileHeaders = headers;
          isLoading = false; // Termina la carga
          statusMessage = 'Cabeceras recibidas (${headers.length}). Listo para mapear.';
        });
        print("Cabeceras guardadas en estado: $fileHeaders");

      } else {
        // El usuario canceló la selección
        setState(() {
          statusMessage = 'Selección cancelada.';
          isLoading = false;
        });
      }
    } catch (e) {
      // 5. Si ocurre un error (al seleccionar o al llamar a la API)
      setState(() {
        isLoading = false;
        statusMessage = 'Error: $e'; // Muestra el error de la excepción
        selectedFile = null; // Limpia el archivo
        fileHeaders = []; // Limpia las cabeceras
      });
    }
  }


  // --- Función para el botón "ENVIAR ARCHIVO" (ahora será "SIGUIENTE") ---
  void goToMappingStep() {
     // Esta función se activará en el siguiente paso (Fase 2)
     // cuando el usuario presione el botón después de ver las cabeceras.
     print("Ir a la pantalla de mapeo con estas cabeceras: $fileHeaders");
     setState(() {
        statusMessage = "Mostrando UI de mapeo (Próximo paso)...";
     });
     // TODO: Implementar la navegación o mostrar la UI de mapeo aquí
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Cambia el título según si ya se cargaron las cabeceras
        title: Text(fileHeaders.isEmpty ? 'Carga - Paso 1: Seleccionar' : 'Carga - Paso 2: Mapear'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Botón para Seleccionar Archivo y Obtener Cabeceras ---
              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text('Seleccionar Archivo y Leer Cabeceras'),
                // Llama a la nueva función combinada
                onPressed: isLoading ? null : selectFileAndGetHeaders,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              const SizedBox(height: 20.0),

              // --- Contenedor para mostrar mensajes de estado ---
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  statusMessage, // Muestra el mensaje de estado actual
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 40.0),

              // --- Botón "SIGUIENTE" (reemplaza ENVIAR ARCHIVO por ahora) ---
              ElevatedButton(
                // Se habilita solo si NO está cargando Y ya tenemos cabeceras
                onPressed: (fileHeaders.isEmpty || isLoading) ? null : goToMappingStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Puedes cambiar el color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('SIGUIENTE: Mapear Columnas'),
              ),
              const SizedBox(height: 12.0),

              // --- Indicador de Carga ---
              // Se muestra si isLoading es true
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}