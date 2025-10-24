import 'dart:io'; // Necesario para File en móvil/escritorio
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar web
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'upload_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carga de Inventario',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const InventoryUploadPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InventoryUploadPage extends StatefulWidget {
  const InventoryUploadPage({super.key});

  @override
  State<InventoryUploadPage> createState() => _InventoryUploadPageState();
}

class _InventoryUploadPageState extends State<InventoryUploadPage> {
  PlatformFile? selectedFile;
  bool isLoanding = false;
  List<String> fileHeaders = [];

  Future <void> cleanSelectedFileHeaders () async {
    //limpiar el estado anteiror
    setState(() {
      selectedFile = null;
      fileHeaders = [];
      isLoanding = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'], // Solo permitir archivos Excel mientras se trabaja en la apliacion con csv y txt
      withData: kIsWeb,
    );

    if (result != null){
      final file = result.files.first;
      setState(() {
        selectedFile = file;

      });

      try {
        final headers = await headersFromApi(file);
        setState(() {
          fileHeaders = headers;
          isLoanding = false;
          
        });
      } catch (e) {
        setState(() {
          isLoanding = false;
          selectedFile = null;
        });
      }
    } else {
        setState((){
        isLoanding = false;
      });
    }
  }



      

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carga de Inventario Paso 1'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[

              // --- WIDGET 1: Botón de Seleccionar Archivo ---
              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text('Seleccionar Archivo y Leer Cabeceras'),
                onPressed: isLoanding ? null : cleanSelectedFileHeaders,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ), 
              const SizedBox(height: 20.0),

              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),


              const SizedBox(height: 40.0),

              ElevatedButton(
                onPressed: (fileHeaders.isEmpty || isLoanding) ? null : () {
                  setState(() {
                    
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('ENVIAR ARCHIVO'),
              ),

              const SizedBox(height: 12.0),

              if (isLoanding) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}