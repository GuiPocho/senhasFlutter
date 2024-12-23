import 'package:flutter/material.dart';

class GroupBoxCard extends StatelessWidget {
  final String groupName;
  final Color color; // Adicionamos uma propriedade para a cor

  const GroupBoxCard({
    super.key,
    required this.groupName,
    this.color = Colors.white, // Cor padrão é branca
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color, // Define a cor do card
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          groupName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
