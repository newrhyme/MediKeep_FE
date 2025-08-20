import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleReading {
  final double? temp;
  final double? humid;
  final int? magnet; // 1/0
  const BleReading({this.temp, this.humid, this.magnet});
}

class BleManager {
  BleManager._();
  static final BleManager I = BleManager._();

  // ESP32에서 쓴 값(앞서 정한 것과 동일)
  static final Guid serviceUuid = Guid('0000aa10-0000-1000-8000-00805f9b34fb');
  static final Guid charUuid = Guid('0000aa11-0000-1000-8000-00805f9b34fb');

  BluetoothDevice? _device;
  BluetoothCharacteristic? _ch;

  final _connectedCtrl = StreamController<bool>.broadcast();
  Stream<bool> get connectedStream => _connectedCtrl.stream;

  final _readingCtrl = StreamController<BleReading>.broadcast();
  Stream<BleReading> get readingStream => _readingCtrl.stream;

  Future<bool> _ensurePermissions() async {
    final results = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // 11 이하 호환
    ].request();
    final ok = (results[Permission.bluetoothScan]?.isGranted ?? true) &&
        (results[Permission.bluetoothConnect]?.isGranted ?? true) &&
        (results[Permission.locationWhenInUse]?.isGranted ?? true);
    return ok;
  }

  Future<void> connect({String targetName = 'MediKeepBox'}) async {
    if (!await _ensurePermissions()) {
      _connectedCtrl.add(false);
      return;
    }
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      _connectedCtrl.add(false);
      return;
    }

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 6),
      withServices: [serviceUuid],
    );

    late final StreamSubscription sub;
    sub = FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        final name = r.advertisementData.advName;
        final hasSvc = r.advertisementData.serviceUuids.contains(serviceUuid);
        if (name == targetName || hasSvc) {
          await FlutterBluePlus.stopScan();
          await sub.cancel();

          _device = r.device;
          await _device!.connect(autoConnect: false).catchError((_) {});
          _connectedCtrl.add(true);

          final services = await _device!.discoverServices();
          for (final s in services) {
            if (s.uuid == serviceUuid) {
              for (final c in s.characteristics) {
                if (c.uuid == charUuid) {
                  _ch = c;
                  await _ch!.setNotifyValue(true);
                  _ch!.lastValueStream.listen(_onValue, onError: (_) {
                    _connectedCtrl.add(false);
                  });
                  return;
                }
              }
            }
          }
          _connectedCtrl.add(false); // 특성 못 찾음
        }
      }
    });

    FlutterBluePlus.isScanning.listen((s) {
      if (!s && _device == null) {
        _connectedCtrl.add(false);
      }
    });
  }

  void _onValue(List<int> data) {
    try {
      final s = utf8.decode(data);
      final obj = json.decode(s) as Map<String, dynamic>;
      _readingCtrl.add(BleReading(
        temp: (obj['t'] as num?)?.toDouble(),
        humid: (obj['h'] as num?)?.toDouble(),
        magnet: (obj['m'] as num?)?.toInt(),
      ));
    } catch (_) {/* 무시 */}
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } finally {
      _device = null;
      _ch = null;
      _connectedCtrl.add(false);
    }
  }

  void dispose() {
    _connectedCtrl.close();
    _readingCtrl.close();
  }
}
