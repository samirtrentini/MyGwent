import 'package:flutter/material.dart';
import 'package:my_gwent/database/card_dao.dart';
import 'package:my_gwent/enums/card_type.enum.dart';
import 'package:my_gwent/models/card.model.dart';
import 'package:my_gwent/models/deck.model.dart';

enum _CardAction { edit, increment, discard }

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

    if (deckId == null) return;

    try {
      final cards = await _cardDao.getByDeckId(deckId);

      if (!mounted) return;

      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cards: $error')),
      );
    }
  }

  Future<void> _addCard() async {
    final card = await showDialog<GwentCard>(
      context: context,
      builder: (_) => const _AddCardDialog(),
    );

    if (card == null) return;

    final deckId = widget.deck.id;
    if (deckId == null) return;

    try {
      await _cardDao.insert(deckId: deckId, card: card);
      await _loadCards();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add card: $error')),
      );
    }
  }

  Future<void> _editCard(GwentCard card) async {
    final updated = await showDialog<GwentCard>(
      context: context,
      builder: (_) => _AddCardDialog(initial: card),
    );

    if (updated == null) return;

    final deckId = widget.deck.id;
    if (deckId == null) return;

    try {
      await _cardDao.insert(deckId: deckId, card: updated);
      await _loadCards();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit card: $error')),
      );
    }
  }

  Future<void> _incrementCard(GwentCard card) async {
    final deckId = widget.deck.id;
    if (deckId == null || card.id == null) return;

    try {
      await _cardDao.updateQuantity(
        deckId: deckId,
        cardId: card.id!,
        quantity: card.quantity + 1,
      );
      await _loadCards();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $error')),
      );
    }
  }

  Future<void> _discardCard(GwentCard card) async {
    final deckId = widget.deck.id;
    if (deckId == null || card.id == null) return;

    try {
      if (card.quantity > 1) {
        await _cardDao.updateQuantity(
          deckId: deckId,
          cardId: card.id!,
          quantity: card.quantity - 1,
        );
      } else {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove card'),
            content: Text('Remove "${card.title}" from this deck?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );

        if (confirm != true) return;

        await _cardDao.deleteFromDeck(
          deckId: deckId,
          cardId: card.id!,
        );
      }

      await _loadCards();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to discard card: $error')),
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
          ? const Center(child: CircularProgressIndicator())
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
            const Icon(Icons.style_outlined, size: 64),
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
    final sorted = [..._cards]..sort((a, b) {
      final typeCompare = b.type.id.compareTo(a.type.id);
      if (typeCompare != 0) return typeCompare;

      final aPower = a.power ?? -1;
      final bPower = b.power ?? -1;
      final powerCompare = bPower.compareTo(aPower);
      if (powerCompare != 0) return powerCompare;

      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final card = sorted[index];
        return _CardTile(
          card: card,
          onEdit: () => _editCard(card),
          onIncrement: () => _incrementCard(card),
          onDiscard: () => _discardCard(card),
        );
      },
    );
  }
}

class _AddCardDialog extends StatefulWidget {
  const _AddCardDialog({this.initial});

  final GwentCard? initial;

  bool get isEditing => initial != null;

  @override
  State<_AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<_AddCardDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _powerController;
  late final TextEditingController _quantityController;
  late CardType _selectedType;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _powerController = TextEditingController(
      text: initial?.power?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: initial?.quantity.toString() ?? '1',
    );
    _selectedType = initial?.type ?? CardType.normal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _powerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final powerText = _powerController.text.trim();
    final quantity = int.parse(_quantityController.text.trim());

    final card = GwentCard(
      id: widget.initial?.id,
      title: title,
      power: powerText.isEmpty ? null : int.parse(powerText),
      type: _selectedType,
      quantity: quantity,
    );

    Navigator.of(context).pop(card);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Card' : 'Add Card'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Title'),
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
                if (value == null || value.trim().isEmpty) return null;
                if (int.tryParse(value.trim()) == null) {
                  return 'Enter a valid number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CardType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: CardType.values.map((type) {
                return DropdownMenuItem<CardType>(
                  value: type,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (type) {
                if (type == null) return;
                setState(() => _selectedType = type);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
              validator: (value) {
                final quantity = int.tryParse(value?.trim() ?? '');
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.onEdit,
    required this.onIncrement,
    required this.onDiscard,
  });

  final GwentCard card;
  final VoidCallback onEdit;
  final VoidCallback onIncrement;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (typeIcon, typeColor) = switch (card.type) {
      CardType.commander => (Icons.shield, colorScheme.error),
      CardType.hero => (Icons.star, colorScheme.primary),
      CardType.normal => (Icons.circle_outlined, colorScheme.outline),
    };

    return Card(
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(typeIcon, color: typeColor, size: 18),
            const SizedBox(height: 2),
            Text(
              '×${card.quantity}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        title: Text(
          card.title,
          style: TextStyle(
            fontWeight: card.type == CardType.normal
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: card.power != null
            ? Text('Power: ${card.power}  •  ${card.type.label}')
            : Text(card.type.label),
        trailing: PopupMenuButton<_CardAction>(
          onSelected: (action) {
            switch (action) {
              case _CardAction.edit:
                onEdit();
              case _CardAction.increment:
                onIncrement();
              case _CardAction.discard:
                onDiscard();
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _CardAction.edit,
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _CardAction.increment,
              child: ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Pick one more'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _CardAction.discard,
              child: ListTile(
                leading: Icon(Icons.remove_circle_outline),
                title: Text('Discard'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
