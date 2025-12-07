import 'dart:async';
import 'package:flutter/material.dart';

class ArrivalDialog extends StatefulWidget {
  final String destinationName;
  final VoidCallback onSwitchNow;
  final VoidCallback onStay;

  const ArrivalDialog({
    Key? key,
    required this.destinationName,
    required this.onSwitchNow,
    required this.onStay,
  }) : super(key: key);

  @override
  _ArrivalDialogState createState() => _ArrivalDialogState();
}

class _ArrivalDialogState extends State<ArrivalDialog> {
  int _timeLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_timeLeft > 1) {
          setState(() {
            _timeLeft--;
          });
        } else {
          // Time is up! Auto-switch.
          _timer?.cancel();
          widget.onSwitchNow();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important: Stop timer if dialog closes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.transfer_within_a_station, color: Colors.blue, size: 60),
            const SizedBox(height: 15),
            const Text(
              "Arrived at Entrance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Switching to indoor map for ${widget.destinationName}...",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // --- Circular Countdown Timer ---
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
                Text(
                  "$_timeLeft",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // --- Action Buttons ---
            Row(
              children: [
                // STAY BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _timer?.cancel(); // Stop the auto-switch
                      widget.onStay();
                    },
                    child: const Text("Stay Here"),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // SWITCH NOW BUTTON
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _timer?.cancel();
                      widget.onSwitchNow();
                    },
                    child: const Text("Switch Now"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}