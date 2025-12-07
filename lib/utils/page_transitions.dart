import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

PageRouteBuilder<T> sharedAxisRoute<T>(
  Widget page, {
  SharedAxisTransitionType type = SharedAxisTransitionType.vertical,
}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}
