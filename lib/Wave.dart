import 'package:flutter/material.dart';
import 'package:senhas/Styles.dart';

class WaveAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140.0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 160.0),
            painter: WavePainter(),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('PASSWORD VAULT', style: headingTextStyle),
            centerTitle: true,
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint para a sombra (elevação)
    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2) // Cor da sombra com transparência
      ..style = PaintingStyle.fill;

    // Paint para o preenchimento transparente principal
    Paint fillPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    Path shadowPath = Path();
    shadowPath.lineTo(0, size.height - 15); // Sombra ligeiramente deslocada para baixo
    shadowPath.quadraticBezierTo(
        size.width * 0.25, size.height - 5, size.width * 0.5, size.height - 15);
    shadowPath.quadraticBezierTo(
        size.width * 0.75, size.height - 45, size.width, size.height - 35);
    shadowPath.lineTo(size.width, 0);
    shadowPath.close();

    Path mainPath = Path();
    mainPath.lineTo(0, size.height - 20);
    mainPath.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 20);
    mainPath.quadraticBezierTo(
        size.width * 0.75, size.height - 50, size.width, size.height - 50);
    mainPath.lineTo(size.width, 0);
    mainPath.close();

    // Desenha a sombra ligeiramente deslocada
    canvas.drawPath(shadowPath, shadowPaint);
    // Desenha o preenchimento transparente principal
    canvas.drawPath(mainPath, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

}