// lib/screens/dashboard_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ble_manager.dart';
import '../screens/add_schedule_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color bg = Color(0xFFC6F2FF);
  static const Color navy = Color(0xFF2D4868);

  int taken = 2;
  int total = 3;
  bool morning = true;
  bool afternoon = true;
  bool evening = false;

  bool _connected = false;
  double? _temp;
  double? _humid;
  StreamSubscription? _connSub;
  StreamSubscription? _readSub;

  TextStyle get title => GoogleFonts.carterOne(
      color: navy, fontSize: 26, fontWeight: FontWeight.w900);

  TextStyle get bigLabel => GoogleFonts.carterOne(
      color: navy, fontSize: 28, fontWeight: FontWeight.w900);

  BoxDecoration get card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    // BLE 연결 시도 & 구독
    _connSub = BleManager.I.connectedStream.listen((ok) {
      setState(() => _connected = ok);
    });
    _readSub = BleManager.I.readingStream.listen((r) {
      setState(() {
        _temp = r.temp;
        _humid = r.humid;
      });
    });
    BleManager.I.connect(); // 자동 연결 시도
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _readSub?.cancel();
    // BleManager.I.disconnect(); // 화면 나갈 때 끊고 싶으면 사용
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : taken / total;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text('Dashboard', style: title),
        actions: [
          IconButton(
            tooltip: _connected ? 'Connected' : 'Connect',
            icon: Icon(Icons.bluetooth,
                color: _connected ? const Color(0xFF29A9FF) : Colors.grey),
            onPressed: () => BleManager.I.connect(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          children: [
            // Top card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // donut + numbers
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CustomPaint(
                          painter: _DonutPainter(
                            progress: progress,
                            color: const Color(0xFF29A9FF),
                          ),
                          child: Center(
                            child: Text(
                              '$taken/$total\ndoses',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.carterOne(
                                fontSize: 22,
                                color: navy,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 온/습도 큰 숫자로
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bluetooth,
                                  color: _connected
                                      ? const Color(0xFF29A9FF)
                                      : Colors.grey,
                                  size: 22),
                              const SizedBox(width: 6),
                              Text(
                                _connected ? 'Connected' : 'Disconnected',
                                style: GoogleFonts.carterOne(
                                    fontSize: 18,
                                    color: navy,
                                    fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Temp  ${_temp?.toStringAsFixed(1) ?? '-'}°C',
                            style: GoogleFonts.carterOne(
                                fontSize: 20,
                                color: navy,
                                fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Humid ${_humid?.toStringAsFixed(1) ?? '-'}%',
                            style: GoogleFonts.carterOne(
                                fontSize: 20,
                                color: navy,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _doseTile(
                label: 'Morning',
                checked: morning,
                onTap: () => setState(() => morning = !morning)),
            const SizedBox(height: 14),
            _doseTile(
                label: 'Afternoon',
                checked: afternoon,
                onTap: () => setState(() => afternoon = !afternoon)),
            const SizedBox(height: 14),
            _doseTile(
                label: 'Evening',
                checked: evening,
                onTap: () => setState(() => evening = !evening)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: navy,
        unselectedItemColor: navy.withOpacity(.5),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'My page'),
        ],
        onTap: (i) {
          debugPrint('BottomNav tapped: $i');
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSchedulePage()),
            );
          }
        },
      ),
    );
  }

  Widget _doseTile({
    required String label,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: card,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          children: [
            _checkIcon(checked),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: bigLabel)),
          ],
        ),
      ),
    );
  }

  Widget _checkIcon(bool checked) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF56C7F2), width: 3),
      ),
      child: checked
          ? const Icon(Icons.check, size: 18, color: Color(0xFF56C7F2))
          : const SizedBox.shrink(),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  final Color color;
  _DonutPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final bg = Paint()
      ..color = const Color(0xFFE5F6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 8, bg);
    final rect = Rect.fromCircle(center: center, radius: radius - 8);
    const pi = 3.1415926535;
    canvas.drawArc(
        rect, -pi / 2, 2 * pi * (progress.clamp(0.0, 1.0)), false, fg);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      progress != old.progress || color != old.color;
}
