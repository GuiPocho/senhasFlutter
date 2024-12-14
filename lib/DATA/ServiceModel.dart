
class ServiceModel {
  final int? id;
  final String servico;
  final String senha;
  final String? grupo;
  final bool privacidade;

  ServiceModel({
    this.id,
    required this.servico,
    required this.senha,
    this.grupo,
    required this.privacidade,

});

  //CONVERTE MODELO PARA MAPA A SER SALVO NO BANCO DE DADOS

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'servico': servico,
    'senha': senha,
    'grupo': grupo,
    'privacidade': privacidade ? 1 : 0,
  };
}

  //CONVERTE MAPA PARA INSTANCIA DE SERVICEMODEL

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
  return ServiceModel(
      id: map['id'] as int?,
      servico: map['servico'] as String,
      senha: map['senha'] as String,
      grupo: map['grupo'] as String?,
      privacidade: (map['privacidade'] as int) == 1,
  );
  }


  }

