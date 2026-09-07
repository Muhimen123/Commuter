import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';
import 'package:frontend/features/ride_discovery/domain/rides_provider.dart';

class BusSelectionResult {
  final String busName;
  final String? routeId;

  const BusSelectionResult({required this.busName, this.routeId});
}

class BusSelectionDialog extends ConsumerStatefulWidget {
  const BusSelectionDialog({super.key});

  @override
  ConsumerState<BusSelectionDialog> createState() => _BusSelectionDialogState();
}

class _BusSelectionDialogState extends ConsumerState<BusSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _selectedBusName;
  String? _selectedRouteId;

  List<Ride> _filteredBuses(List<Ride> buses) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return buses;
    return buses.where((bus) {
      return bus.routeNumber.toLowerCase().contains(query) ||
          bus.routeName.toLowerCase().contains(query) ||
          bus.destination.toLowerCase().contains(query);
    }).toList();
  }

  String get _displayLabel {
    if (_selectedBusName != null) return _selectedBusName!;
    if (_searchController.text.trim().isNotEmpty) {
      return _searchController.text.trim();
    }
    return '';
  }

  void _onSuggestionSelected(Ride bus) {
    setState(() {
      _selectedBusName =
          '${bus.routeNumber} - ${bus.routeName} (${bus.destination} via ${bus.via})';
      _selectedRouteId = bus.id;
      _searchController.text = _selectedBusName!;
    });
    _searchFocusNode.unfocus();
  }

  void _onConfirm() {
    final busName = _displayLabel;
    if (busName.isEmpty) return;
    // A custom-typed name (not matching the last-selected suggestion) has
    // no backing route id.
    final routeId = busName == _selectedBusName ? _selectedRouteId : null;
    Navigator.of(
      context,
    ).pop(BusSelectionResult(busName: busName, routeId: routeId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ridesAsync = ref.watch(ridesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Select Bus',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose a bus route or type in the bus name.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Searchable dropdown field, backed by real routes from the DB.
            ridesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Could not load bus routes. You can still type a bus name below.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ),
              data: (rides) => _buildBusField(context, colorScheme, rides),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    minimumSize: const Size(0, AppSizing.buttonHeight),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: _displayLabel.isEmpty ? null : _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    minimumSize: const Size(0, AppSizing.buttonHeight),
                  ),
                  child: const Text('Start Journey'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusField(
    BuildContext context,
    ColorScheme colorScheme,
    List<Ride> rides,
  ) {
    return SizedBox(
      height: AppSizing.inputFieldHeight,
      child: Autocomplete<Ride>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return rides;
          }
          return _filteredBuses(rides);
        },
        displayStringForOption: (Ride bus) =>
            '${bus.routeNumber} - ${bus.routeName}',
        fieldViewBuilder:
            (
              BuildContext context,
              TextEditingController fieldController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              // Sync the external controller with the autocomplete's
              // so we keep the typed/custom value accessible.
              _searchController.text = fieldController.text;

              return TextField(
                controller: fieldController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search bus route or type name…',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: fieldController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            fieldController.clear();
                            setState(() {
                              _selectedBusName = null;
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    _selectedBusName = null;
                  });
                },
                onSubmitted: (_) {
                  final matches = _filteredBuses(rides);
                  if (matches.isNotEmpty) {
                    _onSuggestionSelected(matches.first);
                  }
                },
              );
            },
        optionsViewBuilder:
            (
              BuildContext context,
              AutocompleteOnSelected<Ride> onSelected,
              Iterable<Ride> options,
            ) {
              return Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(
                    maxHeight: 220,
                    maxWidth: double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final bus = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(bus),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                                constraints: const BoxConstraints(minWidth: 40),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.small,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shield_rounded,
                                      size: 14,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${bus.safetyScore}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${bus.routeNumber} - ${bus.routeName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      '${bus.destination} via ${bus.via}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Icon(
                                Icons.directions_bus_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
        onSelected: (Ride bus) => _onSuggestionSelected(bus),
      ),
    );
  }
}
