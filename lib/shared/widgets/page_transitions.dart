import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  SlidePageRoute({required this.child, this.direction = SlideDirection.right})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          if (direction == SlideDirection.left) {
            tween = Tween(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve));
          } else if (direction == SlideDirection.up) {
            tween = Tween(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve));
          } else if (direction == SlideDirection.down) {
            tween = Tween(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve));
          }

          return SlideTransition(position: animation.drive(tween), child: child);
        },
      );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScalePageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          );
        },
      );
}

class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideUpPageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(position: animation.drive(tween), child: child);
        },
      );
}

enum SlideDirection { left, right, up, down }

// Custom transition for modal dialogs
class ModalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ModalPageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(position: animation.drive(tween), child: child);
        },
        barrierDismissible: true,
        barrierColor: Colors.black54,
      );
}

// Hero transition for venue cards
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String heroTag;

  HeroPageRoute({required this.child, required this.heroTag})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Hero(tag: heroTag, child: child);
        },
      );
}

// Custom transition for booking flow
class BookingFlowPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  BookingFlowPageRoute({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
            child: child,
          );
        },
      );
}

// Transition utilities
class TransitionUtils {
  static Route<T> slideRoute<T>(Widget child, {SlideDirection direction = SlideDirection.right}) {
    return SlidePageRoute<T>(child: child, direction: direction);
  }

  static Route<T> fadeRoute<T>(Widget child) {
    return FadePageRoute<T>(child: child);
  }

  static Route<T> scaleRoute<T>(Widget child) {
    return ScalePageRoute<T>(child: child);
  }

  static Route<T> slideUpRoute<T>(Widget child) {
    return SlideUpPageRoute<T>(child: child);
  }

  static Route<T> modalRoute<T>(Widget child) {
    return ModalPageRoute<T>(child: child);
  }

  static Route<T> heroRoute<T>(Widget child, String heroTag) {
    return HeroPageRoute<T>(child: child, heroTag: heroTag);
  }

  static Route<T> bookingFlowRoute<T>(Widget child) {
    return BookingFlowPageRoute<T>(child: child);
  }
}
