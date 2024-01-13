import 'package:flutter/material.dart';

class VerticalImageStack extends StatelessWidget {
  final List<String> images;

  const VerticalImageStack({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: images.map((image) {
        return ClipOval(
            child: Image.network(
              image,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
        );
      }).toList(),
    );
  }
}