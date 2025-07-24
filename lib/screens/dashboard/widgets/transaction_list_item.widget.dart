import 'package:flutter/material.dart';
import 'package:spending_tracker/models/transaction.dart';
import 'package:spending_tracker/utils/helpers.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Mapping nama ikon dari database ke objek IconData
    const iconMap = {
      'ramen_dining': Icons.ramen_dining,
      'fastfood': Icons.fastfood,
      'directions_bus': Icons.directions_bus,
      'shopping_cart': Icons.shopping_cart,
      'movie': Icons.movie,
    };
    
    IconData iconData = iconMap[transaction.ikon] ?? Icons.wallet_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(iconData, color: Colors.grey[700], size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              transaction.deskripsi,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAngka(transaction.nominal),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildActionButton(Icons.edit, 'Edit', Colors.blue, onEdit),
                  const SizedBox(width: 8),
                  _buildActionButton(Icons.delete, 'Hapus', Colors.red, onDelete),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // Widget helper untuk tombol edit/hapus
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}