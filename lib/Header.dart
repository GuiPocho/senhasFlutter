import 'package:flutter/material.dart';
import 'package:senhas/Wave.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(160.0),
    child: WaveAppBar(),
    );
  }
}
