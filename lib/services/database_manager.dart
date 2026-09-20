
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modele/redacteur.dart';

class DatabaseManager {
  static Database? _database;

  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initialisation();
    return _database!;
  }

 
  Future<Database> initialisation() async {
    // getDatabasesPath() retourne le dossier système où Android/iOS
    // autorise l'application à stocker ses fichiers de base.
    String chemin = join(await getDatabasesPath(), 'redacteurs.db');

    return openDatabase(
      chemin,
      version: 1,
      // onCreate n'est appelé QUE la toute première fois que la
      // base est créée (si le fichier .db n'existe pas encore).
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE redacteurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT,
            prenom TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  // ------------------------------------------------------------
  // 2) READ : récupérer tous les rédacteurs
  // ------------------------------------------------------------
  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;

    // query() sans condition retourne TOUTES les lignes de la table
    // sous forme de List<Map<String, dynamic>>.
    final List<Map<String, dynamic>> maps = await db.query('redacteurs');

    // On transforme chaque Map en objet Redacteur grâce à fromMap().
    return List.generate(maps.length, (i) {
      return Redacteur.fromMap(maps[i]);
    });
  }

  // ------------------------------------------------------------
  // 3) CREATE : insérer un nouveau rédacteur
  // ------------------------------------------------------------
  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    // insert() retourne l'id généré automatiquement par SQLite.
    return await db.insert(
      'redacteurs',
      redacteur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ------------------------------------------------------------
  // 4) UPDATE : mettre à jour un rédacteur existant
  // ------------------------------------------------------------
  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    // where + whereArgs ciblent précisément la ligne à modifier,
    // en se basant sur son id.
    return await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  // ------------------------------------------------------------
  // 5) DELETE : supprimer un rédacteur
  // ------------------------------------------------------------
  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete(
      'redacteurs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}