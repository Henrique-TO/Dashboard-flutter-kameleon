class Pedido {
  final int? id;
  final String cliente;
  final String numero;
  final String data;  // Formato 'YYYY-MM-DD'
  final String tags;  // Separado por vírgulas
  final String imagem;  // JSON de lista de filenames, ex: '["img1.jpg", "img2.jpg"]'

  Pedido({
    this.id,
    required this.cliente,
    required this.numero,
    required this.data,
    required this.tags,
    required this.imagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'numero': numero,
      'data': data,
      'tags': tags,
      'imagem': imagem,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      cliente: map['cliente'],
      numero: map['numero'],
      data: map['data'],
      tags: map['tags'] ?? '',
      imagem: map['imagem'] ?? '[]',
    );
  }
}