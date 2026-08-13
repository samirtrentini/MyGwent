import '../enums/card_type.enum.dart';
import '../enums/faction.enum.dart';

class InitialDeckCard {
  const InitialDeckCard({
    required this.title,
    required this.quantity,
    this.power,
    this.type = CardType.normal,
  });

  final String title;
  final int quantity;
  final int? power;
  final CardType type;
}

const Map<Faction, List<InitialDeckCard>> initialDeckCards = {
  Faction.northernRealms: [
    InitialDeckCard(title: 'Frio Congelante', quantity: 2),
    InitialDeckCard(title: 'Tempo Claro', quantity: 2),
    InitialDeckCard(title: 'Nevoa impenetrável', quantity: 2),
    InitialDeckCard(title: 'Chuva Torrencial', quantity: 2),
    InitialDeckCard(title: 'Iscas', quantity: 3),
    InitialDeckCard(
      title: 'Pobre Infantaria do Caralho',
      quantity: 2,
    ),
    InitialDeckCard(
      title: 'Especialista em Cerco Kaedwen',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Yarpen Zigrin',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Comando dos Listras Azuis',
      quantity: 2,
    ),
    InitialDeckCard(
      title: 'Sabrina Glevisic',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Trabuco',
      quantity: 2,
    ),
  ],

  Faction.nilfgaard: [
    InitialDeckCard(title: 'Frio Congelante', quantity: 2),
    InitialDeckCard(title: 'Tempo Claro', quantity: 2),
    InitialDeckCard(title: 'Nevoa impenetrável', quantity: 2),
    InitialDeckCard(title: 'Chuva Torrencial', quantity: 2),
    InitialDeckCard(title: 'Iscas', quantity: 3),
    InitialDeckCard(title: 'Vreemde', quantity: 1),
    InitialDeckCard(title: 'Vanhemar', quantity: 1),
    InitialDeckCard(title: 'Renuald AEP Matsen', quantity: 1),
    InitialDeckCard(title: 'Puttkamer', quantity: 1),
    InitialDeckCard(title: 'Cynthia', quantity: 1),
    InitialDeckCard(title: 'Albrich', quantity: 1),
    InitialDeckCard(title: 'Manganela podre', quantity: 1),
    InitialDeckCard(title: 'Reforço de cerco', quantity: 1),
    InitialDeckCard(title: 'Engenheiro de cerco', quantity: 1),
  ],

  Faction.scoiatael: [
    InitialDeckCard(title: 'Frio Congelante', quantity: 2),
    InitialDeckCard(title: 'Tempo Claro', quantity: 2),
    InitialDeckCard(title: 'Nevoa impenetrável', quantity: 2),
    InitialDeckCard(title: 'Chuva Torrencial', quantity: 2),
    InitialDeckCard(title: 'Iscas', quantity: 3),
    InitialDeckCard(
      title: 'Anão escaramuçador',
      quantity: 2,
      power: 3,
    ),
    InitialDeckCard(
      title: 'Elfo escaramuçador',
      quantity: 1,
    ),
    InitialDeckCard(title: 'Riodain', quantity: 1),
    InitialDeckCard(
      title: 'Arqueira de Dol Blathana',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Cadete de Vrihedd',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Médica Hackear',
      quantity: 2,
      power: 0,
    ),
    InitialDeckCard(
      title: 'Schirru',
      quantity: 1,
      power: 6,
    ),
  ],

  Faction.monsters: [
    InitialDeckCard(title: 'Frio Congelante', quantity: 2),
    InitialDeckCard(title: 'Tempo Claro', quantity: 2),
    InitialDeckCard(title: 'Nevoa impenetrável', quantity: 2),
    InitialDeckCard(title: 'Chuva Torrencial', quantity: 2),
    InitialDeckCard(title: 'Iscas', quantity: 3),
    InitialDeckCard(title: 'Carniçal', quantity: 3),
    InitialDeckCard(title: 'Cocatriz', quantity: 1),
    InitialDeckCard(title: 'Harpia', quantity: 2),
    InitialDeckCard(title: 'Endriuga', quantity: 1),
    InitialDeckCard(
      title: 'Elemental de Terra',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Gigante de Gelo',
      quantity: 1,
    ),
  ],

  Faction.skellige: [
    InitialDeckCard(title: 'Frio Congelante', quantity: 2),
    InitialDeckCard(title: 'Tempo Claro', quantity: 2),
    InitialDeckCard(title: 'Nevoa impenetrável', quantity: 2),
    InitialDeckCard(title: 'Chuva Torrencial', quantity: 2),
    InitialDeckCard(title: 'Iscas', quantity: 3),
    InitialDeckCard(title: 'Lugos todo roxo', quantity: 1),
    InitialDeckCard(title: 'Lugos Maluco', quantity: 1),
    InitialDeckCard(
      title: 'Holger Mão Negra',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Arqueiro do clã Brovkar',
      quantity: 1,
    ),
    InitialDeckCard(
      title: 'Berserk Jovem',
      quantity: 2,
    ),
    InitialDeckCard(
      title: 'Jovem Vildkaarl transformado',
      quantity: 2,
    ),
    InitialDeckCard(
      title: 'Mardroeme',
      quantity: 1,
    ),
  ],
};
