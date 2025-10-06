import 'package:flutter/material.dart';
import '../models/pedido.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PedidoCard({super.key, required this.pedido, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Cliente: ${pedido.cliente} - Número: ${pedido.numero}'),
        subtitle: Text('Data: ${pedido.data}\nTags: ${pedido.tags}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}