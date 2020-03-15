import 'package:flutter/material.dart';

class VideoLoadingView extends StatelessWidget {
  VideoLoadingView({this.aspectRatio});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: aspectRatio,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ));
  }
}
