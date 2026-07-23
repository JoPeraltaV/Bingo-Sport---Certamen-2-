class AccionBingo {
  const AccionBingo({
    required this.id,
    required this.texto,
    this.esPersonalizada = false,
  });

  final String id;
  final String texto;
  final bool esPersonalizada;

  Map<String, dynamic> aJson() => <String, dynamic>{
        'id': id,
        'texto': texto,
        'esPersonalizada': esPersonalizada,
      };

  factory AccionBingo.desdeJson(Map<Object?, Object?> json) {
    return AccionBingo(
      id: json['id']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
      esPersonalizada: json['esPersonalizada'] == true,
    );
  }
}
