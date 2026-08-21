import 'package:flutter/material.dart';
import 'package:frontend/core/theme/design_tokens.dart';
import 'package:frontend/features/ride_discovery/domain/entities/ride.dart';

/// A dialog that lets the user select a bus from a dropdown list
/// or type in a custom bus name manually.
class BusSelectionDialog extends StatefulWidget {
  const BusSelectionDialog({super.key});

  @override
  State<BusSelectionDialog> createState() => _BusSelectionDialogState();
}

class _BusSelectionDialogState extends State<BusSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? _selectedBusName;

  /// Sample bus data — in the future this will come from an API/backend.
  static const List<Ride> _availableBuses = [
    Ride(
      id: '1',
      routeNumber: '42',
      routeName: 'Turag Transport',
      destination: 'Motijheel',
      via: 'Farmgate',
      status: RideStatus.arriving,
      rating: 4.8,
      reviewCount: 128,
      safetyScore: 98,
      fare: 35.00,
    ),
    Ride(
      id: '2',
      routeNumber: '15',
      routeName: 'Mirpur Link',
      destination: 'Mirpur 10',
      via: 'Kakrail',
      status: RideStatus.scheduled,
      rating: 4.5,
      reviewCount: 84,
      safetyScore: 92,
      fare: 25.00,
    ),
    Ride(
      id: '3',
      routeNumber: '88',
      routeName: 'Balaka Paribahan',
      destination: 'Gulshan 1',
      via: 'Badda',
      status: RideStatus.delayed,
      rating: 4.9,
      reviewCount: 215,
      safetyScore: 99,
      fare: 40.00,
    ),
    Ride(
      id: '4',
      routeNumber: '7',
      routeName: 'Bikalpa Auto',
      destination: 'Azimpur',
      via: 'Nilkhet',
      status: RideStatus.arriving,
      rating: 4.2,
      reviewCount: 45,
      safetyScore: 85,
      fare: 15.00,
    ),
    Ride(
      id: '5',
      routeNumber: '9',
      routeName: 'Salsabil',
      destination: 'Jatrabari',
      via: 'Sayedabad',
      status: RideStatus.scheduled,
      rating: 4.7,
      reviewCount: 156,
      safetyScore: 95,
      fare: 30.00,
    ),
  ];

  List<Ride> get _filteredBuses {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _availableBuses;
    return _availableBuses.where((bus) {
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
      _selectedBusName = '${bus.routeNumber} - ${bus.routeName} (${bus.destination} via ${bus.via})';
      _searchController.text = _selectedBusName!;
    });
    _searchFocusNode.unfocus();
  }

  void _onConfirm() {
    final busName = _displayLabel;
    if (busName.isEmpty) return;
    Navigator.of(context).pop(busName);
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose a bus route or type in the bus name.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Searchable dropdown field
            SizedBox(
              height: AppSizing.inputFieldHeight,
              child: Autocomplete<Ride>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _availableBuses;
                  }
                  return _filteredBuses;
                },
                displayStringForOption: (Ride bus) =>
                    '${bus.routeNumber} - ${bus.routeName}',
                fieldViewBuilder: (
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
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.medium),
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
                      if (_filteredBuses.isNotEmpty) {
                        _onSuggestionSelected(_filteredBuses.first);
                      }
                    },
                  );
                },
                optionsViewBuilder: (
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
                        borderRadius:
                            BorderRadius.circular(AppRadius.small),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
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
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.small,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      bus.routeNumber,
                                      style:
                                          Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.w700,
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bus.routeName,
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
                                                color: colorScheme
                                                    .onSurfaceVariant,
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
}