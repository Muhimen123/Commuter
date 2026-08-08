import 'package:flutter/material.dart';

class RideSurveyDialog extends StatefulWidget {
  const RideSurveyDialog({super.key, required this.onSubmitted});

  final void Function(
    int fare,
    int rating,
    String safetyRating,
    bool isStudentFare,
    String feedback,
  )
  onSubmitted;

  @override
  State<RideSurveyDialog> createState() => _RideSurveyDialogState();
}

class _RideSurveyDialogState extends State<RideSurveyDialog> {
  final TextEditingController _fareController = TextEditingController(
    text: '10',
  );
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 5;
  String _safetyRating = 'Safe & Professional';
  bool _isStudentFare = false;

  @override
  void dispose() {
    _fareController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _adjustFare(int delta) {
    final current = int.tryParse(_fareController.text.trim()) ?? 10;
    final updated = (current + delta).clamp(0, 10000);
    setState(() {
      _fareController.text = updated.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.rate_review_rounded, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Journey Complete',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your ride? Help the community by sharing your fare, safety, and feedback.',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Fare Input with +/- buttons (Integer, default 10)
            const Text(
              'Ride Fare (৳)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.outlined(
                  onPressed: () => _adjustFare(-5),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Decrease ৳5',
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixText: '৳ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () => _adjustFare(5),
                  icon: const Icon(Icons.add),
                  tooltip: 'Increase ৳5',
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Student Fare Toggle
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Student Fare',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  'Applied discounted student rate?',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isStudentFare,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onChanged: (value) {
                  setState(() {
                    _isStudentFare = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Rating Selector
            const Text(
              'Quality Rating',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = starIndex;
                    });
                  },
                  icon: Icon(
                    starIndex <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Safety & Behavior Rating
            const Text(
              'Driver & Conductor Safety',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ['Safe & Professional', 'Neutral', 'Reckless / Unsafe']
                  .map((option) {
                    final isSelected = _safetyRating == option;
                    return ChoiceChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _safetyRating = option;
                          });
                        }
                      },
                      selectedColor: option == 'Reckless / Unsafe'
                          ? colorScheme.error.withValues(alpha: 0.2)
                          : colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (option == 'Reckless / Unsafe'
                                  ? colorScheme.error
                                  : colorScheme.onPrimaryContainer)
                            : colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Feedback Comment
            const Text(
              'Feedback / Comments (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Bus was on time, good lighting, fair price...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSubmitted(
              0,
              5,
              'Safe & Professional',
              false,
              'Skipped survey',
            );
          },
          child: Text(
            'Skip',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            final fare = int.tryParse(_fareController.text.trim()) ?? 10;
            final feedback = _feedbackController.text.trim();
            Navigator.of(context).pop();
            widget.onSubmitted(
              fare,
              _rating,
              _safetyRating,
              _isStudentFare,
              feedback,
            );
          },
          child: const Text(
            'Submit & Finish',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
