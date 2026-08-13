import 'package:flutter/material.dart';
import 'package:my_gwent/enums/faction.enum.dart';

import '../../database/deck_dao.dart';
import '../../models/deck.model.dart';

class DeckFormScreen extends StatefulWidget {
  const DeckFormScreen({
    super.key,
    this.deck,
  });

  final Deck? deck;

  bool get isEditing => deck != null;

  @override
  State<DeckFormScreen> createState() => _DeckFormScreenState();
}

class _DeckFormScreenState extends State<DeckFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final DeckDao _deckDao = DeckDao();

  late Faction _selectedFaction;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final deck = widget.deck;

    _nameController.text = deck?.name ?? '';
    _descriptionController.text = deck?.description ?? '';

    _selectedFaction = deck?.faction ?? Faction.northernRealms;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _saveDeck() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final deck = Deck(
        id: widget.deck?.id,
        name: _nameController.text.trim(),
        faction: _selectedFaction,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      final savedDeck = widget.isEditing
          ? await _updateDeck(deck)
          : await _deckDao.insert(deck);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(savedDeck);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save deck: $error',
          ),
        ),
      );
    }
  }

  Future<Deck> _updateDeck(Deck deck) async {
    await _deckDao.update(deck);

    return deck;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Deck' : 'Create Deck',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 50,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Deck name',
                  hintText: 'Enter deck name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Deck name is required.';
                  }

                  if (name.length > 50) {
                    return 'Deck name must be 50 characters or less.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<Faction>(
                initialValue: _selectedFaction,
                decoration: const InputDecoration(
                  labelText: 'Faction',
                  border: OutlineInputBorder(),
                ),
                items: Faction.values.map((faction) {
                  return DropdownMenuItem<Faction>(
                    value: faction,
                    child: Text(faction.label),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (faction) {
                  if (faction == null) {
                    return;
                  }

                  setState(() {
                    _selectedFaction = faction;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLength: 500,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final description = value?.trim() ?? '';

                  if (description.length > 500) {
                    return 'Description must be 500 characters or less.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveDeck,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Deck',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
