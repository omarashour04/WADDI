import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/smart_back_button.dart';
import '../../domain/entities/search_filters.dart';

class AdvancedSearchPage extends ConsumerStatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  ConsumerState<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends ConsumerState<AdvancedSearchPage> {
  final _searchController = TextEditingController();
  SearchFilters _filters = SearchFilters();
  bool _showFilters = false;

  final List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Parking',
    'Food & Beverages',
    'Gaming Equipment',
    'Sound System',
    'Projector',
    'Private Rooms',
    '24/7 Access',
    'Security',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Venues'),
        leading: const SmartBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search venues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _clearFilters();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                // Trigger search
              },
            ),
          ),

          // Filters Section
          if (_showFilters) _buildFiltersSection(),

          // Results Section
          Expanded(child: _buildResultsSection()),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: _clearFilters, child: const Text('Clear All')),
            ],
          ),
          const SizedBox(height: 16),

          // Price Range
          const Text('Price Range (per hour)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(
              _filters.minPrice?.toDouble() ?? 0,
              _filters.maxPrice?.toDouble() ?? 200,
            ),
            min: 0,
            max: 200,
            divisions: 20,
            labels: RangeLabels(
              'EGP ${_filters.minPrice?.toInt() ?? 0}',
              'EGP ${_filters.maxPrice?.toInt() ?? 200}',
            ),
            onChanged: (values) {
              setState(() {
                _filters = _filters.copyWith(minPrice: values.start, maxPrice: values.end);
              });
            },
          ),

          // Capacity Range
          const SizedBox(height: 16),
          const Text('Capacity Range', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(
              _filters.minCapacity?.toDouble() ?? 1,
              _filters.maxCapacity?.toDouble() ?? 50,
            ),
            min: 1,
            max: 50,
            divisions: 49,
            labels: RangeLabels(
              '${_filters.minCapacity?.toInt() ?? 1}',
              '${_filters.maxCapacity?.toInt() ?? 50}',
            ),
            onChanged: (values) {
              setState(() {
                _filters = _filters.copyWith(
                  minCapacity: values.start.toInt(),
                  maxCapacity: values.end.toInt(),
                );
              });
            },
          ),

          // Amenities
          const SizedBox(height: 16),
          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableAmenities.map((amenity) {
              final isSelected = _filters.amenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final amenities = List<String>.from(_filters.amenities);
                    if (selected) {
                      amenities.add(amenity);
                    } else {
                      amenities.remove(amenity);
                    }
                    _filters = _filters.copyWith(amenities: amenities);
                  });
                },
              );
            }).toList(),
          ),

          // Sort Options
          const SizedBox(height: 16),
          const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Rating'),
                selected: _filters.sortBy == 'rating',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _filters = _filters.copyWith(sortBy: 'rating');
                    });
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Price'),
                selected: _filters.sortBy == 'price',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _filters = _filters.copyWith(sortBy: 'price');
                    });
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Distance'),
                selected: _filters.sortBy == 'distance',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _filters = _filters.copyWith(sortBy: 'distance');
                    });
                  }
                },
              ),
            ],
          ),

          // Sort Direction
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filters = _filters.copyWith(sortAscending: true);
                    });
                  },
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Ascending'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _filters.sortAscending ? Colors.blue : null,
                    foregroundColor: _filters.sortAscending ? Colors.white : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filters = _filters.copyWith(sortAscending: false);
                    });
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Descending'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_filters.sortAscending ? Colors.blue : null,
                    foregroundColor: !_filters.sortAscending ? Colors.white : null,
                  ),
                ),
              ),
            ],
          ),

          // Show Only Available
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Show Only Available'),
            subtitle: const Text('Hide venues under maintenance'),
            value: _filters.showOnlyAvailable,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(showOnlyAvailable: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    // This would integrate with the venue provider to show filtered results
    return const Center(child: Text('Search results will appear here'));
  }

  void _clearFilters() {
    setState(() {
      _filters = SearchFilters();
      _searchController.clear();
    });
  }
}
