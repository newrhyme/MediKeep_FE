// bluetooth_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  BluetoothService._();
  static final BluetoothService I = BluetoothService._();

  /// 스캔 결과 스트림 (UI에서 listen)
  Stream<List<fbp.ScanResult>> get scanResults =>
      fbp.FlutterBluePlus.scanResults;

  /// 권한 확보 (Android 12+: BLUETOOTH_SCAN/CONNECT, 이하: location)
  Future<bool> ensurePermissions() async {
    if (!Platform.isAndroid) return true;

    final results = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // Android 11 이하 호환
    ].request();

    final granted = (results[Permission.bluetoothScan]?.isGranted ?? true) &&
        (results[Permission.bluetoothConnect]?.isGranted ?? true) &&
        (results[Permission.locationWhenInUse]?.isGranted ?? true);

    if (!granted) {
      debugPrint('Bluetooth permissions not granted.');
    }
    return granted;
  }

  /// 블루투스 어댑터가 켜져있는지 확인
  Future<bool> ensureBluetoothOn() async {
    final state = await fbp.FlutterBluePlus.adapterState.first;
    if (state == fbp.BluetoothAdapterState.on) return true;
    debugPrint('Bluetooth is OFF. Ask user to turn it ON.');
    return false;
  }

  /// 스캔 시작/중지
  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 6)}) async {
    await fbp.FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() async => fbp.FlutterBluePlus.stopScan();

  /// 연결/서비스 검색/해제
  Future<fbp.BluetoothDevice> connect(fbp.ScanResult r,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final device = r.device;
    await device.connect(timeout: timeout);
    return device;
  }

  Future<List<fbp.BluetoothService>> discover(
      fbp.BluetoothDevice device) async {
    return device.discoverServices();
  }

  Future<void> disconnect(fbp.BluetoothDevice device) async {
    await device.disconnect();
  }

  /// 캐릭터리스틱 읽기 예시
  Future<List<int>> readCharacteristic(fbp.BluetoothCharacteristic c) async {
    return c.read();
  }
}
