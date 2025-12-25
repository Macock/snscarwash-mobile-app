import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../../domain/entities/booking.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали бронирования'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус
            Center(
              child: _StatusBadge(status: booking.status),
            ),
            const SizedBox(height: 24),
            // Информация о клиенте
            _SectionTitle(title: 'Клиент'),
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(label: 'Имя', value: booking.userName),
                const Divider(),
                _DetailRow(label: 'Email', value: booking.userEmail),
              ],
            ),
            const SizedBox(height: 24),
            // Информация об автомойке
            _SectionTitle(title: 'Автомойка'),
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(label: 'Название', value: booking.carWashName),
                const Divider(),
                _DetailRow(label: 'Адрес', value: booking.carWashAddress),
              ],
            ),
            const SizedBox(height: 24),
            // Время и дата
            _SectionTitle(title: 'Время услуги'),
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(
                  label: 'Дата',
                  value: DateFormat('dd MMMM yyyy', 'ru').format(booking.date),
                ),
                const Divider(),
                _DetailRow(label: 'Время', value: booking.time),
              ],
            ),
            const SizedBox(height: 24),
            // Оплата
            _SectionTitle(title: 'Оплата'),
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(label: 'Способ оплаты', value: booking.paymentMethod),
              ],
            ),
            const SizedBox(height: 24),
            // Системная информация
            _SectionTitle(title: 'Системная информация'),
            const SizedBox(height: 12),
            _DetailCard(
              children: [
                _DetailRow(
                  label: 'Создано',
                  value: DateFormat('dd.MM.yyyy HH:mm').format(booking.createdAt),
                ),
                const Divider(),
                _DetailRow(
                  label: 'Обновлено',
                  value: DateFormat('dd.MM.yyyy HH:mm').format(booking.updatedAt),
                ),
                const Divider(),
                _DetailRow(label: 'ID', value: booking.id),
              ],
            ),
            const SizedBox(height: 32),
            // Кнопки управления
            if (booking.status == BookingStatus.pending)
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await bookingProvider.updateStatus(booking.id, BookingStatus.confirmed);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Бронирование подтверждено')),
              );
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Подтвердить'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            await bookingProvider.updateStatus(booking.id, BookingStatus.cancelled);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Бронирование отменено')),
              );
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.close),
          label: const Text('Отменить'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить бронирование?'),
        content: const Text('Это действие нельзя будет отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final bookingProvider = Provider.of<BookingProvider>(
                context,
                listen: false,
              );
              await bookingProvider.deleteBooking(booking.id);
              if (context.mounted) {
                Navigator.pop(context); // Закрыть диалог
                Navigator.pop(context); // Закрыть экран деталей
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Бронирование удалено')),
                );
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        text = 'Ожидает подтверждения';
        icon = Icons.pending;
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        text = 'Подтверждено';
        icon = Icons.check_circle;
        break;
      case BookingStatus.completed:
        color = Colors.blue;
        text = 'Завершено';
        icon = Icons.done_all;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'Отменено';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}