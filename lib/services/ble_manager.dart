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

    // 1) 스캔
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

          try {
            // 2) 연결 시도 (타임아웃/재시도 대비)
            await _device!.connect(
              autoConnect: false,
              timeout: const Duration(seconds: 10),
            );

            // 3) 실제로 'connected' 상태가 될 때까지 대기
            await _device!.connectionState.firstWhere(
              (s) => s == BluetoothConnectionState.connected,
              orElse: () => BluetoothConnectionState.disconnected,
            );

            // (안드로이드 일부 기기에서 바로 discover하면 레이스) 약간 대기
            await Future.delayed(const Duration(milliseconds: 300));

            _connectedCtrl.add(true);

            // 4) 서비스 검색
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
                    return; // ✅ 성공 경로
                  }
                }
              }
            }

            // 특성을 못 찾은 경우
            _connectedCtrl.add(false);
            await _device!.disconnect();
            _device = null;
          } catch (e) {
            // 5) 연결/서비스 검색 실패 – 상태 리셋
            _connectedCtrl.add(false);
            try {
              await _device?.disconnect();
            } catch (_) {}
            _device = null;
            // 필요하면 여기서 재시도 로직 추가 가능
          }

          return; // 일단 후보 하나 처리 후 종료
        }
      }
    });

    // 스캔 종료됐는데도 못 찾은 경우
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
