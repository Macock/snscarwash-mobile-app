import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/car_wash_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/car_wash.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  CarWash? _selectedCarWash;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarWashProvider>(context, listen: false).loadCarWashes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта автомоек'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(
                LatLng(ApiConstants.aktobeLatitude, ApiConstants.aktobeLongitude),
                13,
              );
            },
          ),
        ],
      ),
      body: Consumer<CarWashProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadCarWashes(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final carWashes = provider.carWashes;

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      ApiConstants.aktobeLatitude,
                      ApiConstants.aktobeLongitude,
                    ),
                    initialZoom: 13.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                    onTap: (_, __) {
                      setState(() {
                        _selectedCarWash = null;
                      });
                    },
                  ),
                  children: [
                    // Слой карты 2GIS
                    TileLayer(
                      urlTemplate: ApiConstants.tileUrl,
                      userAgentPackageName: 'com.example.car_wash_app',
                    ),
                    // Маркеры автомоек
                    MarkerLayer(
                      markers: carWashes.map((carWash) {
                        final isSelected = _selectedCarWash?.id == carWash.id;
                        return Marker(
                          point: LatLng(carWash.latitude, carWash.longitude),
                          width: isSelected ? 50 : 40,
                          height: isSelected ? 50 : 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCarWash = carWash;
                              });
                              _mapController.move(
                                LatLng(carWash.latitude, carWash.longitude),
                                15,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00A8E8)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF00A8E8),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.local_car_wash,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF00A8E8),
                                size: isSelected ? 30 : 24,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Информационная панель внизу
              if (_selectedCarWash != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCarWash!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedCarWash = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF00A8E8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_selectedCarWash!.address),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedCarWash!.rating} (${_selectedCarWash!.reviewCount} отзывов)',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Построить маршрут
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Маршрут'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A8E8),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Перейти к бронированию
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Забронировать'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00A8E8),
                                side: const BorderSide(
                                  color: Color(0xFF00A8E8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}