import 'package:flutter/material.dart';
import 'package:my_gwent/database/card_dao.dart';
import 'package:my_gwent/models/card.model.dart';
import 'package:my_gwent/models/deck.model.dart';

class DeckDetailsScreen extends StatefulWidget {
  const DeckDetailsScreen({
    super.key,
    required this.deck,
  });

  final Deck deck;

  @override
  State<DeckDetailsScreen> createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> {
  final CardDao _cardDao = CardDao();

  List<GwentCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadCards();
  }

  Future<void> _loadCards() async {
    final deckId = widget.deck.id;

    if (deckId == null) {
      return;
    }

    try {
      final cards = await _cardDao.getByDeckId(deckId);

      if (!mounted) {
        return;
      }

      setState(() {
        _cards = cards;
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
          content: Text('Failed to load cards: $error'),
        ),
      );
    }
  }

  Future<void> _addCard() async {
    final card = await showDialog<GwentCard>(
      context: context,
      builder: (_) => const _AddCardDialog(),
    );

    if (card == null) {
      return;
    }

    final deckId = widget.deck.id;

    if (deckId == null) {
      return;
    }

    try {
      await _cardDao.insert(
        deckId: deckId,
        card: card,
      );

      await _loadCards();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add card: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _cards.isEmpty
          ? _buildEmptyState()
          : _buildCardList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        tooltip: 'Add card',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'No cards yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add cards to this deck.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                '${card.quantity}',
              ),
            ),
            title: Text(card.title),
            subtitle: card.power != null
                ? Text('Power: ${card.power}')
                : null,
          ),
        );
      },
    );
  }
}

class _AddCardDialog extends StatefulWidget {
  const _AddCardDialog();

  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _powerController = TextEditingController();
  final _quantityController = TextEditingController(
    text: '1',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _powerController.dispose();
    _quantityController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final powerText = _powerController.text.trim();
    final quantity = int.parse(
      _quantityController.text,
    );

    final card = GwentCard(
      title: title,
      power: powerText.isEmpty
          ? null
          : int.parse(powerText),
      quantity: quantity,
    );

    Navigator.of(context).pop(card);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Card'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required.';
                }

                return null;
              },
            ),

            TextFormField(
              controller: _powerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Power',
                hintText: 'Optional',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null;
                }

                if (int.tryParse(value.trim()) == null) {
                  return 'Enter a valid number.';
                }

                return null;
              },
            ),

            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
              validator: (value) {
                final quantity = int.tryParse(
                  value?.trim() ?? '',
                );

                if (quantity == null || quantity < 1) {
                  return 'Quantity must be at least 1.';
                }

                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
