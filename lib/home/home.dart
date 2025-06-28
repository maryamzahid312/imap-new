import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';

import '../../models/user_entry.dart';
import '../utils/file_utils.dart';
import '../utils/storage_service.dart';
import '../utils/geocoding_service.dart';
import 'dialogues/dialogues.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _typeAheadController = TextEditingController();

  List<UserEntry> entries = [];
  LatLng? _searchedLocation;
  bool _useSatellite = false;

  RangeValues populationRange = const RangeValues(0, 1000000);
  Map<String, bool> filterExpanded = {'Population': false};

  late final AnimationController _markerAnimController;

  @override
  void initState() {
    super.initState();
    _markerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _loadSavedEntries();
  }

  void _loadSavedEntries() async {
    final saved = await StorageService.loadEntries();
    setState(() => entries = saved);
  }

  void _handleManualEntry(UserEntry entry) {
    setState(() => entries.add(entry));
    StorageService.saveEntries(entries);
  }

  void _handleFileUpload(List<UserEntry> parsedEntries) {
    final validEntries = parsedEntries.where((entry) => entry.latitude != 0 && entry.longitude != 0).toList();
    if (validEntries.isNotEmpty) {
      setState(() => entries.addAll(validEntries));
      StorageService.saveEntries(entries);
      _mapController.move(LatLng(validEntries.first.latitude, validEntries.first.longitude), 6);
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18) _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 2) _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  Future<void> _searchAndMark(LatLng coords) async {
    setState(() => _searchedLocation = coords);
    _mapController.move(coords, 10);
  }

  void _showFilterPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned(
              top: 136,
              left: 45,
              child: Container(
                width: 351,
                height: 270,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: StatefulBuilder(
                  builder: (context, setLocalState) {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              _buildExpandableSlider(
                                'Population',
                                0,
                                1000000,
                                populationRange,
                                (val) => setLocalState(() => populationRange = val),
                                onToggle: () => setLocalState(() =>
                                  filterExpanded['Population'] = !filterExpanded['Population']!),
                              ),
                              const Divider(),
                              const ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Score', style: TextStyle(fontFamily: 'Roboto',)),
                                
                              ),
                              const Divider(),
                              const ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Latitude', style: TextStyle(fontFamily: 'Roboto',)),
                               ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel", style: TextStyle(fontFamily: 'Roboto')),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  entries = entries.where((entry) =>
                                    entry.population >= populationRange.start &&
                                    entry.population <= populationRange.end
                                  ).toList();
                                });
                              },
                              child: const Text("Apply", style: TextStyle(fontFamily: 'Roboto')),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSlider(
    String label,
    double min,
    double max,
    RangeValues values,
    ValueChanged<RangeValues> onChanged, {
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label, style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
          trailing: Icon(filterExpanded[label]! ? Icons.expand_less : Icons.expand_more),
          onTap: onToggle,
        ),
        if (filterExpanded[label]!)
          RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: 10,
            labels: RangeLabels(
              values.start.toStringAsFixed(0),
              values.end.toStringAsFixed(0),
            ),
            activeColor: Colors.teal,
            onChanged: onChanged,
          ),
      ],
    );
  }

  void _showNewDataPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit_note),
              label: const Text("Manual Entry", style: TextStyle(fontFamily: 'Roboto')),
              onPressed: () {
                Navigator.pop(context);
                showManualEntryForm(context, _handleManualEntry);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload CSV/JSON", style: TextStyle(fontFamily: 'Roboto')),
              onPressed: () async {
                Navigator.pop(context);
                final data = await FileUtils.pickAndParseFile(context);
                _handleFileUpload(data);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _markerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              key: ValueKey(entries.length + (_useSatellite ? 1 : 0)),
              mapController: _mapController,
              options: MapOptions(
                initialCenter: entries.isNotEmpty
                    ? LatLng(entries.first.latitude, entries.first.longitude)
                    : const LatLng(33.6844, 73.0479),
                initialZoom: 3,
                minZoom: 2,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: _useSatellite
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.imap',
                ),
                MarkerLayer(
                  markers: entries.map((entry) => Marker(
                    width: 50,
                    height: 50,
                    point: LatLng(entry.latitude, entry.longitude),
                    child: ScaleTransition(
                      scale: Tween(begin: 0.9, end: 1.2).animate(
                          CurvedAnimation(
                              parent: _markerAnimController,
                              curve: Curves.easeInOut)),
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${entry.cityName} — Pop: ${entry.population}', style: const TextStyle(fontFamily: 'Roboto'))),
                          );
                        },
                        child: Image.asset('assets/images/marker.png'),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),

            // Search bar
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: TypeAheadField<Map<String, dynamic>>(
                controller: _typeAheadController,
                suggestionsCallback: (pattern) async => await GeocodingService.searchCitySuggestions(pattern),
                builder: (context, controller, focusNode) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(fontFamily: 'Roboto'),
                  decoration: InputDecoration(
                    hintText: 'Try entering places you wanna explore',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Image.asset('assets/images/filter_icon.png'),
                      onPressed: () => _showFilterPrompt(context),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                itemBuilder: (context, suggestion) => ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(suggestion['display_name'], style: const TextStyle(fontFamily: 'Roboto')),
                ),
                onSelected: (suggestion) => _searchAndMark(LatLng(
                  double.parse(suggestion['lat']),
                  double.parse(suggestion['lon']),
                )),
              ),
            ),

            // Map controls
            Positioned(
              top: MediaQuery.of(context).size.height * 0.23,
              right: 20,
              child: Container(
                width: 42,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: Image.asset('assets/images/zoom_in.png'), onPressed: _zoomIn),
                    IconButton(icon: Image.asset('assets/images/zoom_out.png'), onPressed: _zoomOut),
                    IconButton(icon: Image.asset('assets/images/map.png'), onPressed: () => setState(() => _useSatellite = !_useSatellite)),
                  ],
                ),
              ),
            ),

            // Bottom navbar
            Positioned(
              bottom: bottomPadding + 16,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset('assets/images/nav_home.png', width: 44, height: 44),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset('assets/images/nav_dir.png', width: 44, height: 44),
                    ),
                    GestureDetector(
                      onTap: () => _showNewDataPrompt(context),
                      child: Image.asset('assets/images/nav_new.png', width: 44, height: 44),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset('assets/images/nav_profile.png', width: 44, height: 44),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
