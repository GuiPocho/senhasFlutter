
import 'package:senhas/DATA/Cadastro_Provider.dart';
import 'package:flutter/material.dart';

// CORES DO TEXTO
const Color primaryColor = Color(0xFF003366);
const Color secundaryColor = Color(0x8A662FFF);
const Color iconsColors = Color(0xFFE9967A);

// TAMANHOS DE TEXTO
const double headingFontSize = 26;
const double secundaryFontSize = 22;

//TAMANHO DE ICONES
const double iconsSizeA = 40;


// ESTILOS DE TEXTO
  const TextStyle headingTextStyle = TextStyle(
  fontSize: headingFontSize,
  fontWeight: FontWeight.bold,
  color: primaryColor,
);

  const TextStyle secundaryTextStyle = TextStyle(
    fontSize: secundaryFontSize,
    fontWeight: FontWeight.bold,
    shadows: [
      Shadow(
        offset: Offset(1.5, 1.5),
        blurRadius: 2.0,
        color: Colors.black26
      )
    ],
    color: secundaryColor,
  );
