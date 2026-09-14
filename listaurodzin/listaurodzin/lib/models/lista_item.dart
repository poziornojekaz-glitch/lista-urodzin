class ListaItem {
  int id;
  String tekst;
  DateTime? datazapisz;
  bool czyRokWidoczny;
  bool czyPowiadamiac;

  ListaItem({
    required this.id,
    required this.tekst,
    this.datazapisz,
    this.czyRokWidoczny = false,
    this.czyPowiadamiac = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tekst': tekst,
      'datazapisz': datazapisz?.toIso8601String(),
      'czyRokWidoczny': czyRokWidoczny,
      'czyPowiadamiac': czyPowiadamiac,
    };
  }

  factory ListaItem.fromJson(Map<String, dynamic> json) {
    return ListaItem(
      id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      tekst: json['tekst'] as String? ?? '',
      datazapisz: json['datazapisz'] != null
          ? DateTime.tryParse(json['datazapisz'] as String)
          : null,
      czyRokWidoczny: json['czyRokWidoczny'] as bool? ?? false,
      czyPowiadamiac: json['czyPowiadamiac'] as bool? ?? true,
    );
  }

  ListaItem copyWith({
    int? id,
    String? tekst,
    DateTime? datazapisz,
    bool? czyRokWidoczny,
    bool? czyPowiadamiac,
  }) {
    return ListaItem(
      id: id ?? this.id,
      tekst: tekst ?? this.tekst,
      datazapisz: datazapisz ?? this.datazapisz,
      czyRokWidoczny: czyRokWidoczny ?? this.czyRokWidoczny,
      czyPowiadamiac: czyPowiadamiac ?? this.czyPowiadamiac,
    );
  }
}
