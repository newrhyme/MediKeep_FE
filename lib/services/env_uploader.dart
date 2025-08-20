import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'api_client.dart';

class EnvUploader {
  EnvUploader._();
  static final EnvUploader I = EnvUploader._();

  Timer? _timer;
  double? _lastT, _lastH;
  bool _running = false;
  DateTime? _lastSentAt;

  // BLE 리딩이 올 때마다 최신값 저장만
  void setLatest(double? t, double? h) {
    _lastT = t;
    _lastH = h;

    // 실행 중이고 아직 한 번도 업로드 안했다면 즉시 업로드
    if (_running && _lastSentAt == null && t != null && h != null) {
      _flush();
    }
  }

  void start({Duration every = const Duration(minutes: 10)}) {
    if (_running) return;
    _running = true;
    _timer = Timer.periodic(every, (_) => _flush());
    _flush();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _flush() async {
    final t = _lastT, h = _lastH;
    if (t == null || h == null) return; // 값 없으면 패스

    try {
      await ApiClient.postJson(
        '/api/env/upload', // 백엔드에 맞춰 경로/스키마 조정
        {
          'temperature': t,
          'humidity': h,
        },
      );
      _lastSentAt = DateTime.now();
    } catch (e) {
      // 업로드 실패는 조용히 무시(다음 턴에 재시도)
      debugPrint('Env upload failed: $e');
    }
  }
}
