import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class ProductivityCard extends StatelessWidget {
  const ProductivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF009662)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Productividad', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('75%', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('↑ 12% vs ayer', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
            ],
          ),
          const Icon(Icons.trending_up, color: Colors.white, size: 54),
        ],
      ),
    );
  }
}