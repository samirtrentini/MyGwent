import 'package:flutter/material.dart';
import 'package:my_gwent/database/deck_dao.dart';
import 'package:my_gwent/screens/decks/deck_details_screen.dart';
import '../../models/deck.model.dart';
import 'deck_form_screen.dart';

class DecksScreen extends StatefulWidget {
  const DecksScreen({super.key});

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  final DeckDao _deckDao = DeckDao();

  List<Deck> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadDecks();
  }

  Future<void> _loadDecks() async {
    try {
      final decks = await _deckDao.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _decks = decks;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load decks: $error',
          ),
        ),
      );
    }
  }

  Future<void> _createDeck() async {
    final deck = await Navigator.of(context).push<Deck>(
      MaterialPageRoute(
        builder: (_) => const DeckFormScreen(),
      ),
    );

    if (deck == null || !mounted) {
      return;
    }

    await _loadDecks();
  }

  Future<void> _openDeck(Deck deck) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeckDetailsScreen(
          deck: deck,
        ),
      ),
    );
  }

  Future<void> _editDeck(Deck deck) async {
    final updatedDeck = await Navigator.of(context).push<Deck>(
      MaterialPageRoute(
        builder: (_) => DeckFormScreen(
          deck: deck,
        ),
      ),
    );

    if (updatedDeck == null || !mounted) {
      return;
    }

    await _loadDecks();
  }

  Future<bool> _confirmDeleteDeck(Deck deck) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Deck?'),
          content: Text(
            'Are you sure you want to delete "${deck.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return false;
    }

    try {
      final id = deck.id;

      if (id == null) {
        return false;
      }

      await _deckDao.delete(id);

      if (!mounted) {
        return true;
      }

      setState(() {
        _decks.removeWhere(
              (item) => item.id == id,
        );
      });

      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete deck: $error',
            ),
          ),
        );
      }

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _decks.isEmpty
          ? _buildEmptyState(context)
          : _buildDeckList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDeck,
        tooltip: 'Create deck',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.style_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No decks yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first deck.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _createDeck,
              icon: const Icon(Icons.add),
              label: const Text('Create Deck'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _decks.length,
      itemBuilder: (context, index) {
        final deck = _decks[index];

        return Dismissible(
          key: ValueKey(deck.id),

          direction: DismissDirection.horizontal,

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              await _editDeck(deck);

              return false;
            }

            if (direction == DismissDirection.endToStart) {
              return await _confirmDeleteDeck(deck);
            }

            return false;
          },

          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.edit,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),

          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Icon(
              Icons.delete,
              color: Theme.of(context)
                  .colorScheme
                  .onErrorContainer,
            ),
          ),

          child: Card(
            child: ListTile(
              leading: const Icon(Icons.style),
              title: Text(deck.name),
              subtitle: Text(deck.faction.label),
              onTap: () => _openDeck(deck),
            ),
          ),
        );
      },
    );
  }
}
