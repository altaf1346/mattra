import 'package:flutter/material.dart';

class ConnectionStatus extends StatelessWidget {
  final String stateText;

  const ConnectionStatus({Key? key, required this.stateText}) : super(key: key);

  Color _color() {
    final s = stateText.toLowerCase();
    if (s.contains('connect')) return Colors.green;
    if (s.contains('reconnect')) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        SizedBox(width: 8),
        Text('Status: $stateText', style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}