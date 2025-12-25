// presentation/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/car_wash_provider.dart';
import '../../domain/entities/car_wash.dart';
import 'booking_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  CarWash? _selectedCarWash;
  
  // Координаты центра Актобе
  static const double aktobeLatitude = 50.2839;
  static const double aktobeLongitude = 57.1670;

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
            tooltip: 'Мое местоположение',
            onPressed: () {
              _mapController.move(
                LatLng(aktobeLatitude, aktobeLongitude),
                13,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Фильтры',
            onPressed: () {
              _showFiltersDialog();
            },
          ),
        ],
      ),
      body: Consumer<CarWashProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка карты...'),
                ],
              ),
            );
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
                    textAlign: TextAlign.center,
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

          return Stack(
            children: [
              // Карта
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(aktobeLatitude, aktobeLongitude),
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
                  // Слой карты OpenStreetMap (можно заменить на 2GIS)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.car_wash_app',
                    maxZoom: 19,
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
              
              // Список автомоек внизу (горизонтальная прокрутка)
              if (carWashes.isNotEmpty && _selectedCarWash == null)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom, // Отступ для системной панели
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 180,
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Найдено автомоек: ${carWashes.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: carWashes.length,
                            itemBuilder: (context, index) {
                              final carWash = carWashes[index];
                              return _buildCarWashCard(carWash);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Детальная информация о выбранной автомойке
              if (_selectedCarWash != null)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom, // Отступ для системной панели
                  left: 0,
                  right: 0,
                  child: _buildSelectedCarWashInfo(_selectedCarWash!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarWashCard(CarWash carWash) {
    return GestureDetector(
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
        width: 280,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              carWash.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF00A8E8),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    carWash.address,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${carWash.rating} (${carWash.reviewCount})',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCarWashInfo(CarWash carWash) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  carWash.name,
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF00A8E8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  carWash.address,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                '${carWash.rating} (${carWash.reviewCount} отзывов)',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openInNavigator(carWash);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Маршрут'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Забронировать'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00A8E8),
                    side: const BorderSide(color: Color(0xFF00A8E8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Рейтинг 4.5+'),
                value: false,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Открыто сейчас'),
                value: false,
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openInNavigator(CarWash carWash) {
    // Открыть координаты в навигаторе (2GIS, Google Maps, Яндекс.Карты)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Открытие ${carWash.name} в навигаторе...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}