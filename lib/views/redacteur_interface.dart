// ============================================================
// VUE : RedacteurInterface  (PERSONNALISÉ)
// Auteur : Haïrou BROUTANI (Niveau Intermédiaire - Septembre)
// ============================================================

import 'package:flutter/material.dart';
import '../modele/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _dbManager = DatabaseManager();

  // Contrôleurs pour le formulaire d'ajout
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _courrielController = TextEditingController();

  // Liste des rédacteurs affichée à l'écran
  List<Redacteur> _redacteurs = [];

  // true pendant le chargement initial → affiche un spinner
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  Future<void> _chargerRedacteurs() async {
    try {
      final liste = await _dbManager.getAllRedacteurs();
      if (mounted) {
        setState(() {
          _redacteurs = liste;
          _chargement = false;
        });
      }
    } catch (e) {
      print('ERREUR chargement : $e');
      if (mounted) setState(() => _chargement = false);
    }
  }

  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final courriel = _courrielController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || courriel.isEmpty) {
      _afficherMessage('Veuillez remplir tous les champs.');
      return;
    }

    try {
      final nouveauRedacteur = Redacteur.sansId(
        nom: nom,
        prenom: prenom,
        email: courriel,
      );

      await _dbManager.insertRedacteur(nouveauRedacteur);

      _nomController.clear();
      _prenomController.clear();
      _courrielController.clear();

      await _chargerRedacteurs();
      _afficherMessage('Rédacteur ajouté avec succès !');
    } catch (e) {
      print('ERREUR insertion : $e');
      _afficherMessage('Erreur lors de l\'ajout : $e');
    }
  }

  void _ouvrirDialogueModification(Redacteur redacteur) {
    final nomCtrl = TextEditingController(text: redacteur.nom);
    final prenomCtrl = TextEditingController(text: redacteur.prenom);
    final courrielCtrl = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier le rédacteur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(labelText: 'Nouveau nom'),
              ),
              TextField(
                controller: prenomCtrl,
                decoration: const InputDecoration(labelText: 'Nouveau prénom'),
              ),
              TextField(
                controller: courrielCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nouvelle adresse courriel'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final modifie = Redacteur(
                  id: redacteur.id,
                  nom: nomCtrl.text.trim(),
                  prenom: prenomCtrl.text.trim(),
                  email: courrielCtrl.text.trim(),
                );

                try {
                  await _dbManager.updateRedacteur(modifie);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  await _chargerRedacteurs();
                  _afficherMessage('Rédacteur modifié avec succès !');
                } catch (e) {
                  print('ERREUR modification : $e');
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _confirmerSuppression(Redacteur redacteur) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Voulez-vous vraiment supprimer '
            '${redacteur.prenom} ${redacteur.nom} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await _dbManager.deleteRedacteur(redacteur.id!);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  await _chargerRedacteurs();
                  _afficherMessage('Rédacteur supprimé.');
                } catch (e) {
                  print('ERREUR suppression : $e');
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _afficherMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        // VOTRE NOM APPARAÎT ICI DANS L'APPLICATION :
        title: const Text('Gestion des rédacteurs - Haïrou BROUTANI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _courrielController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Adresse courriel'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _ajouterRedacteur,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un Rédacteur'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _chargement
                  ? const Center(child: CircularProgressIndicator())
                  : _redacteurs.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun rédacteur enregistré.\n'
                            'Ajoutez-en un avec le formulaire ci-dessus.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _redacteurs.length,
                          itemBuilder: (context, index) {
                            final r = _redacteurs[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                  '${r.nom} ${r.prenom}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(r.email),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.grey),
                                      onPressed: () => _confirmerSuppression(r),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.grey),
                                      onPressed: () =>
                                          _ouvrirDialogueModification(r),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _courrielController.dispose();
    super.dispose();
  }
}
