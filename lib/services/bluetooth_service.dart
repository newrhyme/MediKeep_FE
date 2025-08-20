// lib/services/bluetooth_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static final BluetoothService I = BluetoothService._();
  BluetoothService._();

  final FlutterBluePlus _ble = FlutterBluePlus.instance;

  // 스캔 결과 스트림 (UI에서 listen)
  Stream<List<ScanResult>> get scanResults => _ble.scanResults;

  Future<bool> ensurePermissions() async {
    // Android 12+ : BLUETOOTH_* 런타임 권한
    // Android 11- : 위치 권한 필요
    if (Platform.isAndroid) {
      final sdk = await FlutterBluePlus.platformVersion; // "Android 14" 류
      final major = int.tryParse(sdk.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;

      if (major >= 12) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        if (statuses[Permission.bluetoothScan]?.isGranted != true ||
            statuses[Permission.bluetoothConnect]?.isGranted != true) {
          return false;
        }
      } else {
        // Android 11 이하
        final st = await Permission.locationWhenInUse.request();
        if (!st.isGranted) return false;
      }
    }
    return true;
  }

  Future<bool> ensureBluetoothOn() async {
    // 어댑터 상태 체크
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) return true;

    // 사용자가 직접 켜야 할 수 있음 (토글 UI는 OS/제조사별 상이)
    debugPrint('Bluetooth is OFF. Ask user to turn it ON.');
    return false;
  }

  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 6)}) async {
    await _ble.startScan(timeout: timeout);
  }

  Future<void> stopScan() async {
    await _ble.stopScan();
  }

  Future<BluetoothDevice> connect(ScanResult r,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final device = r.device;
    await device.connect(timeout: timeout);
    return device;
  }

  Future<List<BluetoothServiceFbp>> discover(BluetoothDevice device) async {
    final services = await device.discoverServices();
    return services;
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}
