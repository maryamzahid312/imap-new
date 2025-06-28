import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  // For fetching suggestions with Nominatim
  static Future<List<Map<String, dynamic>>> searchCitySuggestions(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    final response = await http.get(url, headers: {
      'User-Agent': 'imap-app (your@email.com)' // Nominatim requires a custom User-Agent
    });

    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body);
      return results.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  // For searching a single result (optional but handy)
  static Future<LatLng?> forwardGeocode(String query) async {
    final suggestions = await searchCitySuggestions(query);
    if (suggestions.isNotEmpty) {
      final first = suggestions.first;
      return LatLng(double.parse(first['lat']), double.parse(first['lon']));
    }
    return null;
  }
}
