import 'package:flutter/material.dart';

class GroupBoxCard extends StatelessWidget {
  final String groupName;
  final bool isPrivate; // Indica se o grupo é privado
  final VoidCallback onTap;
  final VoidCallback onSwipeRight;
  final VoidCallback onLongPress;

  const GroupBoxCard({
    super.key,
    required this.groupName,
    required this.isPrivate,
    required this.onTap,
    required this.onSwipeRight,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          onSwipeRight();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isPrivate ? Colors.grey.withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              groupName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPrivate ? Colors.grey : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),

    );
  }
}
