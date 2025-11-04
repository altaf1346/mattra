// name=widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mattra/main.dart';
import 'package:mattra/core/bluetooth/ble_service.dart';
import 'package:mattra/core/bluetooth/classic_service.dart';
import 'package:mattra/core/bluetooth/connection_wrapper.dart';
import 'package:mattra/viewmodels/device_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Provide mock/shared prefs for tests
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches and shows Scan button and title', (WidgetTester tester) async {
    // Build the dependencies like main.dart does
    final prefs = await SharedPreferences.getInstance();
    final bleService = BleService();
    final classicService = ClassicService();
    final connectionWrapper = ConnectionWrapper(
      bleService: bleService,
      classicService: classicService,
      prefs: prefs,
    );

    final deviceViewModel = DeviceViewModel(
      bleService: bleService,
      classicService: classicService,
      connectionWrapper: connectionWrapper,
      prefs: prefs,
    );

    // Register viewmodel with GetX so widgets using Get.find() can access it
    Get.put<DeviceViewModel>(deviceViewModel);

    // Pump the app with the required parameter
    await tester.pumpWidget(MyApp(deviceViewModel: deviceViewModel));
    await tester.pumpAndSettle();

    // Verify the title is present
    expect(find.text('Arvyax Smart Mat — Mock'), findsOneWidget);

    // Verify the Scan button exists
    expect(find.widgetWithText(ElevatedButton, 'Scan'), findsOneWidget);

    // Optionally tap the Scan button to ensure UI responds (scanning is mocked)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Scan'));
    await tester.pump(); // start of scan
    // after tapping, the button shows 'Scanning...' (it uses vm.isScanning) so allow a frame
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Scanning'), findsWidgets);
  });
}