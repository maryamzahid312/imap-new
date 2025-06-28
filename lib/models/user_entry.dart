class UserEntry {
  final String cityName;
  final double latitude;
  final double longitude;
  final int population;

  UserEntry({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.population,
  });

  factory UserEntry.fromJson(Map<String, dynamic> json) => UserEntry(
        cityName: json['cityName'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        population: json['population'],
      );

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'latitude': latitude,
        'longitude': longitude,
        'population': population,
      };

  factory UserEntry.fromCsv(List<String> row) => UserEntry(
        cityName: row[0],
        latitude: double.tryParse(row[1]) ?? 0.0,
        longitude: double.tryParse(row[2]) ?? 0.0,
        population: int.tryParse(row[3]) ?? 0,
      );
}
