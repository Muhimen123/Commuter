import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../data/photon_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'map_suggestions_list.dart';

class MapSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClear;
  final bool hasRoute;
  final List<LocationSuggestion> suggestions;
  final ValueChanged<LocationSuggestion> onSuggestionSelected;
  final bool isLoading;

  const MapSearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
    required this.onClear,
    required this.hasRoute,
    required this.suggestions,
    required this.onSuggestionSelected,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassContainer(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 56,
            child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Where would you like to go?',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
              ],
              const SizedBox(width: 4),
              hasRoute
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => onSubmitted(controller.text),
                    ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        ),
        MapSuggestionsList(
          suggestions: suggestions,
          onSuggestionSelected: onSuggestionSelected,
        ),
      ],
    );
  }
}
