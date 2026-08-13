import 'package:flutter/material.dart';

class ScorePanel extends StatelessWidget {
  const ScorePanel({
    super.key,
    required this.title,
    required this.score,
    required this.onChange,
  });

  final String title;
  final int score;
  final void Function(int amount) onChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 20),

            FittedBox(
              child: Text(
                '$score',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScoreButton(
                  icon: Icons.remove,
                  onPressed: () => onChange(-1),
                ),

                const SizedBox(width: 8),

                _ScoreButton(
                  icon: Icons.add,
                  onPressed: () => onChange(1),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onChange(5),
                child: const Text('+5'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
