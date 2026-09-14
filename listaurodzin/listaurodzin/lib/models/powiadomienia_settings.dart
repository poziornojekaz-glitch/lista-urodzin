class PowiadomieniaSettings {
  bool alertWDniu;
  int godzinaWDniu;
  bool alertDzienPrzed;
  int godzinaDzienPrzed;

  PowiadomieniaSettings({
    this.alertWDniu = true,
    this.godzinaWDniu = 9,
    this.alertDzienPrzed = true,
    this.godzinaDzienPrzed = 18,
  });

  Map<String, dynamic> toJson() {
    return {
      'alertWDniu': alertWDniu,
      'godzinaWDniu': godzinaWDniu,
      'alertDzienPrzed': alertDzienPrzed,
      'godzinaDzienPrzed': godzinaDzienPrzed,
    };
  }

  factory PowiadomieniaSettings.fromJson(Map<String, dynamic> json) {
    return PowiadomieniaSettings(
      alertWDniu: json['alertWDniu'] as bool? ?? true,
      godzinaWDniu: json['godzinaWDniu'] as int? ?? 9,
      alertDzienPrzed: json['alertDzienPrzed'] as bool? ?? true,
      godzinaDzienPrzed: json['godzinaDzienPrzed'] as int? ?? 18,
    );
  }

  PowiadomieniaSettings copyWith({
    bool? alertWDniu,
    int? godzinaWDniu,
    bool? alertDzienPrzed,
    int? godzinaDzienPrzed,
  }) {
    return PowiadomieniaSettings(
      alertWDniu: alertWDniu ?? this.alertWDniu,
      godzinaWDniu: godzinaWDniu ?? this.godzinaWDniu,
      alertDzienPrzed: alertDzienPrzed ?? this.alertDzienPrzed,
      godzinaDzienPrzed: godzinaDzienPrzed ?? this.godzinaDzienPrzed,
    );
  }
}
