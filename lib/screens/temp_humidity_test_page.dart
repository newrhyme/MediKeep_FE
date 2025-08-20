import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TempHumidityTestPage extends StatefulWidget {
  const TempHumidityTestPage({super.key});

  @override
  State<TempHumidityTestPage> createState() => _TempHumidityTestPageState();
}

class _TempHumidityTestPageState extends State<TempHumidityTestPage> {
  static final serviceUuid = Guid('0000aa10-0000-1000-8000-00805f9b34fb');
  static final charUuid = Guid('0000aa11-0000-1000-8000-00805f9b34fb');

  BluetoothDevice? _device;
  BluetoothCharacteristic? _ch;
  String _status = 'Scanning...';
  double? _t, _h;
  int? _m;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // 스캔
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.device.platformName.contains('MediKeepBox')) {
          await FlutterBluePlus.stopScan();
          _status = 'Connecting...';
          setState(() {});
          _device = r.device;
          await _device!.connect(autoConnect: false).catchError((_) {});
          _status = 'Discovering...';
          setState(() {});
          final svcs = await _device!.discoverServices();
          for (final s in svcs) {
            if (s.uuid == serviceUuid) {
              for (final c in s.characteristics) {
                if (c.uuid == charUuid) {
                  _ch = c;
                  await _ch!.setNotifyValue(true);
                  _ch!.lastValueStream.listen(_onValue);
                  _status = 'Receiving data';
                  setState(() {});
                  return;
                }
              }
            }
          }
          _status = 'Characteristic not found';
          setState(() {});
        }
      }
    });
  }

  void _onValue(List<int> data) {
    try {
      final jsonStr = utf8.decode(data);
      final obj = json.decode(jsonStr) as Map<String, dynamic>;
      setState(() {
        _t = (obj['t'] as num?)?.toDouble();
        _h = (obj['h'] as num?)?.toDouble();
        _m = (obj['m'] as num?)?.toInt();
      });
    } catch (_) {
      // ignore malformed
    }
  }

  @override
  void dispose() {
    _device?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Temp/Humidity Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Temp: ${_t?.toStringAsFixed(1) ?? "-"} °C',
                style: const TextStyle(fontSize: 24)),
            Text('Humidity: ${_h?.toStringAsFixed(1) ?? "-"} %',
                style: const TextStyle(fontSize: 24)),
            Text('Magnet: ${_m == null ? "-" : (_m == 1 ? "ON" : "OFF")}',
                style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
