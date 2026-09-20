

class Redacteur {
 
  final int? id;
  final String nom;
  final String prenom;
  final String email;


  Redacteur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

 
  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  }) : id = null;

  
  Map<String, dynamic> toMap() {
    return {
      
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }

 
  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      email: map['email'] as String,
    );
  }
}