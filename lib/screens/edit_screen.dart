import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import 'dart:io';

class EditScreen extends StatefulWidget {
  final Pedido? pedido;
  const EditScreen({super.key, this.pedido});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clienteController;
  late TextEditingController _numeroController;
  late TextEditingController _dataController;
  late TextEditingController _tagsController;
  String _imagensJson = '[]';
  String? _uploadPath; // Armazena o caminho da pasta de upload

  @override
  void initState() {
    super.initState();
    _clienteController = TextEditingController(text: widget.pedido?.cliente ?? '');
    _numeroController = TextEditingController(text: widget.pedido?.numero ?? '');
    _dataController = TextEditingController(
        text: widget.pedido?.data ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _tagsController = TextEditingController(text: widget.pedido?.tags ?? '');
    _imagensJson = widget.pedido?.imagem ?? '[]';
    // Carrega o uploadPath no initState
    _loadUploadPath();
  }

  Future<void> _loadUploadPath() async {
    _uploadPath = await FileService().getUploadFolder();
    setState(() {}); // Atualiza a UI após carregar o caminho
  }

  Future<void> _pickImages() async {
    List<String> newFilenames = await FileService().pickImages();
    if (newFilenames.isNotEmpty) {
      setState(() {
        _imagensJson = FileService().addImagesToJson(_imagensJson, newFilenames);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newFilenames.length} imagem(s) adicionada(s)')),
      );
    }
  }

  Future<void> _removeImage(String filename) async {
    await FileService().deleteImage(filename);
    setState(() {
      _imagensJson = FileService().removeImageFromJson(_imagensJson, filename);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        jsonDecode(_imagensJson); // Valida o JSON
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: Lista de imagens inválida')),
        );
        return;
      }
      Pedido newPedido = Pedido(
        id: widget.pedido?.id,
        cliente: _clienteController.text,
        numero: _numeroController.text,
        data: _dataController.text,
        tags: _tagsController.text,
        imagem: _imagensJson,
      );
      if (widget.pedido == null) {
        await DatabaseService().insertPedido(newPedido);
      } else {
        await DatabaseService().updatePedido(newPedido);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = jsonDecode(_imagensJson);

    return Scaffold(
      appBar: AppBar(title: Text(widget.pedido == null ? 'Novo Pedido' : 'Editar Pedido')),
      body: _uploadPath == null
          ? Center(child: CircularProgressIndicator()) // Mostra um loading enquanto _uploadPath não está carregado
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _clienteController,
                    decoration: InputDecoration(labelText: 'Cliente'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _numeroController,
                    decoration: InputDecoration(labelText: 'Número'),
                    validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _dataController,
                    decoration: InputDecoration(labelText: 'Data'),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        _dataController.text = DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                  ),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(labelText: 'Tags (separadas por vírgula)'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text('Adicionar Imagens'),
                  ),
                  if (images.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(height: 200),
                      items: images.map((filename) {
                        String path = '$_uploadPath/$filename';
                        return Stack(
                          children: [
                            Image.file(File(path), fit: BoxFit.cover),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _removeImage(filename),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text('Salvar'),
                  ),
                ],
              ),
            ),
    );
  }
}