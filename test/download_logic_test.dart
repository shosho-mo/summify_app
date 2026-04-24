import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:summify/main.dart';

void main() {
  test('downloadCallback sends status and progress to the registered port',
      () async {
    // Setup: Create a ReceivePort to simulate the UI isolate listener
    final receivePort = ReceivePort();
    const portName = 'downloader_send_port';

    // Register the port in the IsolateNameServer
    IsolateNameServer.registerPortWithName(receivePort.sendPort, portName);

    // Act: Invoke the callback logic found in lib/main.dart
    const testId = 'book_001';
    const testStatus = 3; // e.g., TaskStatus.complete
    const testProgress = 100;

    downloadCallback(testId, testStatus, testProgress);

    // Assert: Verify the message arrived correctly
    final message = await receivePort.first;
    expect(message, [testId, testStatus, testProgress]);

    // Cleanup
    IsolateNameServer.removePortNameMapping(portName);
    receivePort.close();
  });
}
