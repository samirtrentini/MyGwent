import 'package:flutter/material.dart';
import 'package:my_gwent/screens/game/round_history_card.dart';
import 'package:my_gwent/models/round_result.model.dart';
import 'package:my_gwent/screens/game/score_panel.dart';
import 'package:my_gwent/enums/winner.enum.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int startingGems = 2;

  int _playerScore = 0;
  int _opponentScore = 0;

  int _playerGems = startingGems;
  int _opponentGems = startingGems;

  int _round = 1;

  final List<RoundResult> _roundHistory = [];

  bool get _gameFinished {
    return _playerGems == 0 || _opponentGems == 0;
  }

  Winner? get _gameWinner {
    if (!_gameFinished) {
      return null;
    }

    if (_playerGems == 0 && _opponentGems == 0) {
      return Winner.draw;
    }

    if (_playerGems == 0) {
      return Winner.opponent;
    }

    return Winner.player;
  }

  void _changePlayerScore(int amount) {
    setState(() {
      _playerScore = (_playerScore + amount).clamp(0, 999);
    });
  }

  void _changeOpponentScore(int amount) {
    setState(() {
      _opponentScore = (_opponentScore + amount).clamp(0, 999);
    });
  }

  void _finishRound() {
    if (_gameFinished) {
      return;
    }

    Winner winner;

    if (_playerScore > _opponentScore) {
      winner = Winner.player;
    } else if (_opponentScore > _playerScore) {
      winner = Winner.opponent;
    } else {
      winner = Winner.draw;
    }

    setState(() {
      switch (winner) {
        case Winner.player:
          _opponentGems--;
          break;

        case Winner.opponent:
          _playerGems--;
          break;

        case Winner.draw:
          _playerGems--;
          _opponentGems--;
          break;
      }

      _roundHistory.add(
        RoundResult(
          round: _round,
          playerScore: _playerScore,
          opponentScore: _opponentScore,
          winner: winner,
          playerGemsAfter: _playerGems,
          opponentGemsAfter: _opponentGems,
        ),
      );

      if (!_gameFinished) {
        _round++;
        _playerScore = 0;
        _opponentScore = 0;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _playerScore = 0;
      _opponentScore = 0;

      _playerGems = startingGems;
      _opponentGems = startingGems;

      _round = 1;
      _roundHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset game',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildRoundHeader(context),

              const SizedBox(height: 16),

              if (_roundHistory.isNotEmpty) ...[
                _buildRoundHistory(context),
                const SizedBox(height: 16),
              ],

              Expanded(
                child: _gameFinished
                    ? _buildGameFinished(context)
                    : _buildCurrentRound(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '💎 ' * _playerGems,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),

        Text(
          'Round $_round',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Opponent',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '💎 ' * _opponentGems,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentRound(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ScorePanel(
                  title: 'You',
                  score: _playerScore,
                  onChange: _changePlayerScore,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ScorePanel(
                  title: 'Opponent',
                  score: _opponentScore,
                  onChange: _changeOpponentScore,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _finishRound,
            icon: const Icon(Icons.flag),
            label: const Text('Finish Round'),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundHistory(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _roundHistory.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final round = _roundHistory[index];

          return RoundHistoryCard(round: round);
        },
      ),
    );
  }

  Widget _buildGameFinished(BuildContext context) {
    final winner = _gameWinner;

    String title;
    IconData icon;

    switch (winner) {
      case Winner.player:
        title = 'You Win!';
        icon = Icons.emoji_events;
        break;

      case Winner.opponent:
        title = 'Opponent Wins!';
        icon = Icons.sports_score;
        break;

      case Winner.draw:
        title = 'Draw!';
        icon = Icons.handshake;
        break;

      case null:
        title = '';
        icon = Icons.sports_score;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Gems: $_playerGems - $_opponentGems',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}
