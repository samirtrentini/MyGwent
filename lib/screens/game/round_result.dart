import 'package:my_gwent/screens/game/winner.enum.dart';

class RoundResult {
  const RoundResult({
    required this.round,
    required this.playerScore,
    required this.opponentScore,
    required this.winner,
    required this.playerGemsAfter,
    required this.opponentGemsAfter,
  });

  final int round;
  final int playerScore;
  final int opponentScore;
  final Winner winner;

  final int playerGemsAfter;
  final int opponentGemsAfter;
}
