import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const elevation1 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(11, 28, 48, 0.08),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const elevation2 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(11, 28, 48, 0.10),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const elevation3 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(11, 28, 48, 0.14),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const elevation4 = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(11, 28, 48, 0.16),
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
