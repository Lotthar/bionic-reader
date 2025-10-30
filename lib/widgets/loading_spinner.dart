import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingSpinner extends StatelessWidget {
  final double size;

  const LoadingSpinner({super.key, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return SpinKitSpinningCircle(
      color: Theme.of(context).colorScheme.inversePrimary,
      size: size,
    );
  }
}
