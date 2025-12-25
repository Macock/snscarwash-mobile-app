import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_wash_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/auth_provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedCarWashId;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedPayment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CarWashProvider>(context, listen: false);
      if (provider.carWashes.isEmpty) {
        provider.loadCarWashes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирование'),
      ),
      body: Consumer2<CarWashProvider, BookingProvider>(
        builder: (context, carWashProvider, bookingProvider, child) {
          if (carWashProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final carWashes = carWashProvider.carWashes;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_car_wash,
                                color: Color(0xFF00A8E8),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Автомойка',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCarWashId,
                          hint: const Text('Выберите автомойку'),
                          items: carWashes.map((carWash) {
                            return DropdownMenuItem(
                              value: carWash.id,
                              child: Text(carWash.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedCarWashId = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF00A8E8),
                    ),
                    title: const Text('Дата'),
                    subtitle: Text(
                      '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.access_time,
                      color: Color(0xFF00A8E8),
                    ),
                    title: const Text('Время'),
                    subtitle: Text(
                      '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Color(0xFF00A8E8)),
                              SizedBox(width: 8),
                              Text(
                                'Способ оплаты',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedPayment,
                          hint: const Text('Выберите способ оплаты'),
                          items: const [
                            DropdownMenuItem(
                              value: 'card1',
                              child: Text('Карта **** 1234'),
                            ),
                            DropdownMenuItem(
                              value: 'card2',
                              child: Text('Карта **** 5678'),
                            ),
                            DropdownMenuItem(
                              value: 'wallet',
                              child: Text('Кошелек приложения'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => selectedPayment = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: bookingProvider.isLoading ||
                          selectedCarWashId == null ||
                          selectedPayment == null
                      ? null
                      : () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final currentUser = authProvider.currentUser;
                          
                          // Get car wash details
                          final selectedCarWash = carWashes.firstWhere(
                            (cw) => cw.id == selectedCarWashId,
                          );

                          final success = await bookingProvider.book(
                            carWashId: selectedCarWashId!,
                            userId: currentUser?.id ?? '1',
                            userName: currentUser?.name ?? 'Пользователь',
                            userEmail: currentUser?.email ?? '',
                            carWashName: selectedCarWash.name,
                            carWashAddress: selectedCarWash.address,
                            date: selectedDate,
                            time: '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            paymentMethod: selectedPayment!,
                          );

                          if (success && mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Успешно!'),
                                content: const Text('Бронирование создано'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: bookingProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Забронировать',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}