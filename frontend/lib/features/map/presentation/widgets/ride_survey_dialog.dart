import 'package:flutter/material.dart';

class RideSurveyDialog extends StatefulWidget {
  const RideSurveyDialog({
    super.key,
    required this.onSubmitted,
  });

  final void Function(int fare, int rating, String safetyRating, bool isStudentFare, String feedback) onSubmitted;

  @override
  State<RideSurveyDialog> createState() => _RideSurveyDialogState();
}

class _RideSurveyDialogState extends State<RideSurveyDialog> {
  final TextEditingController _fareController = TextEditingController(text: '10');
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
            
            _FareInputSection(
              controller: _fareController,
              isStudentFare: _isStudentFare,
              onAdjustFare: _adjustFare,
              onStudentFareChanged: (val) => setState(() => _isStudentFare = val),
            ),
            const SizedBox(height: 20),

            _QualityRatingSection(
              rating: _rating,
              onRatingChanged: (val) => setState(() => _rating = val),
            ),
            const SizedBox(height: 16),

            _SafetyRatingSection(
              selectedSafety: _safetyRating,
              onSafetyChanged: (val) => setState(() => _safetyRating = val),
            ),
            const SizedBox(height: 16),

            _FeedbackSection(
              controller: _feedbackController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSubmitted(0, 5, 'Safe & Professional', false, 'Skipped survey');
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
            widget.onSubmitted(fare, _rating, _safetyRating, _isStudentFare, feedback);
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

class _FareInputSection extends StatelessWidget {
  const _FareInputSection({
    required this.controller,
    required this.isStudentFare,
    required this.onAdjustFare,
    required this.onStudentFareChanged,
  });

  final TextEditingController controller;
  final bool isStudentFare;
  final void Function(int delta) onAdjustFare;
  final void Function(bool value) onStudentFareChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ride Fare (৳)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton.outlined(
              onPressed: () => onAdjustFare(-5),
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
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              onPressed: () => onAdjustFare(5),
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
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
              'Applies discounted student rate',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            value: isStudentFare,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onChanged: onStudentFareChanged,
          ),
        ),
      ],
    );
  }
}

class _QualityRatingSection extends StatelessWidget {
  const _QualityRatingSection({
    required this.rating,
    required this.onRatingChanged,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quality Rating',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return IconButton(
              onPressed: () => onRatingChanged(starIndex),
              icon: Icon(
                starIndex <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SafetyRatingSection extends StatelessWidget {
  const _SafetyRatingSection({
    required this.selectedSafety,
    required this.onSafetyChanged,
  });

  final String selectedSafety;
  final ValueChanged<String> onSafetyChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver & Conductor Safety',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            'Safe & Professional',
            'Neutral',
            'Reckless / Unsafe',
          ].map((option) {
            final isSelected = selectedSafety == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSafetyChanged(option);
                }
              },
              selectedColor: option == 'Reckless / Unsafe' 
                  ? colorScheme.error.withValues(alpha: 0.2) 
                  : colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected 
                    ? (option == 'Reckless / Unsafe' ? colorScheme.error : colorScheme.onPrimaryContainer)
                    : colorScheme.onSurface,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback / Comments (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Bus was on time, good lighting, fair price...',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
