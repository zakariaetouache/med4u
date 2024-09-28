class Patient {
  final String prenom;
  final String nom;
  final String tel;
  final String email;
  final String idPatient;

  Patient({
    required this.prenom,
    required this.nom,
    required this.tel,
    required this.email,
    required this.idPatient,
  });
  @override
  String toString() {
    return 'nom = $nom - prenom = $prenom - tel = $tel - email = $email';
  }
}
