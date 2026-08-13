import 'package:flutter/material.dart';
import 'package:my_gwent/models/round_result.model.dart';
import 'package:my_gwent/enums/winner.enum.dart';

class RoundHistoryCard extends StatelessWidget {
  const RoundHistoryCard({
    super.key,
    required this.round,
  });

  final RoundResult round;

  String get result {
    switch (round.winner) {
      case Winner.player:
        return 'You';
      case Winner.opponent:
        return 'Opponent';
      case Winner.draw:
        return 'Draw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'R${round.round}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            Text(
              '${round.playerScore} - ${round.opponentScore}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              result,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
