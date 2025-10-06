import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../services/database_service.dart';
import '../services/file_service.dart'; // Certifique-se de importar o FileService
import '../widgets/pedido_card.dart';
import 'edit_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final FileService _fileService = FileService(); // Crie uma instância de FileService
  List<Pedido> _pedidos = [];
  String _filterMonth = '';

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    var filters = {'month': _filterMonth};
    final pedidos = await _dbService.getPedidos(filters: filters);
    setState(() => _pedidos = pedidos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sistema de Pedidos')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _filterMonth,
            items: [
              DropdownMenuItem(value: '', child: Text('Todos os Meses')),
              for (var i = 1; i <= 12; i++)
                DropdownMenuItem(
                  value: i.toString().padLeft(2, '0'),
                  child: Text(
                    [
                      '',
                      'Janeiro',
                      'Fevereiro',
                      'Março',
                      'Abril',
                      'Maio',
                      'Junho',
                      'Julho',
                      'Agosto',
                      'Setembro',
                      'Outubro',
                      'Novembro',
                      'Dezembro'
                    ][i],
                  ),
                ),
            ],
            onChanged: (value) {
              setState(() => _filterMonth = value ?? '');
              _loadPedidos();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pedidos.length,
              itemBuilder: (context, index) {
                return PedidoCard(
                  pedido: _pedidos[index],
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditScreen(pedido: _pedidos[index])),
                  ).then((_) => _loadPedidos()),
                  onDelete: () async {
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Confirmar Exclusão'),
                        content: Text('Tem certeza que deseja excluir o pedido ${_pedidos[index].numero}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Excluir'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      // Deletar imagens primeiro
                      List<String> images = jsonDecode(_pedidos[index].imagem);
                      for (var img in images) {
                        await _fileService.deleteImage(img); // Use a instância _fileService
                      }
                      await _dbService.deletePedido(_pedidos[index].id!);
                      _loadPedidos();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditScreen()),
        ).then((_) => _loadPedidos()),
        child: Icon(Icons.add),
      ),
    );
  }
}