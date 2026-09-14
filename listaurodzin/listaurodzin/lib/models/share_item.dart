class ListaDoUdostepnienia {
  String przekazimie;
  DateTime? przekazdate;
  bool czyprzekazac;

  ListaDoUdostepnienia({
    required this.przekazimie,
    this.przekazdate,
    this.czyprzekazac = false,
  });
}
