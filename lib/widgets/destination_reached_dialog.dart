import 'package:flutter/material.dart';

class DestinationReachedDialog extends StatelessWidget {
  final String destinationName;
  final VoidCallback onOk;

  const DestinationReachedDialog({
    Key? key,
    required this.destinationName,
    required this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text(
              "Destination Reached!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "You have arrived at $destinationName.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  onOk();
                },
                child: const Text("Great!"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}