import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Theme
  static const Color bg = Color(0xFFC6F2FF);
  static const Color navy = Color(0xFF2D4868);
  static const Color cyan = Color(0xFF87E3FF);

  // Fake data
  int taken = 2;
  int total = 3;
  bool morning = true;
  bool afternoon = true;
  bool evening = false;

  TextStyle get title => GoogleFonts.carterOne(
        color: navy,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      );

  TextStyle get bigLabel => GoogleFonts.carterOne(
        color: navy,
        fontSize: 28,
        fontWeight: FontWeight.w900,
      );

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
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : taken / total;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text('Dashboard', style: title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          children: [
            // Top card: donut + status rows
            Container(
              padding: const EdgeInsets.all(18),
              decoration: card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Donut + text
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CustomPaint(
                          painter: _DonutPainter(
                              progress: progress,
                              color: const Color(0xFF29A9FF)),
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
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Status line 1: Bluetooth
                  Row(
                    children: [
                      const Icon(Icons.bluetooth,
                          color: Color(0xFF29A9FF), size: 26),
                      const SizedBox(width: 8),
                      Text('Connected',
                          style: GoogleFonts.carterOne(
                              fontSize: 20,
                              color: navy,
                              fontWeight: FontWeight.w900)),
                      const Spacer(),
                      const Icon(Icons.thermostat,
                          color: Color(0xFF29A9FF), size: 26),
                      const SizedBox(width: 6),
                      Text('25°  55%',
                          style: GoogleFonts.carterOne(
                              fontSize: 18,
                              color: navy,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dose rows
            _doseTile(
              label: 'Morning',
              checked: morning,
              onTap: () => setState(() => morning = !morning),
            ),
            const SizedBox(height: 14),
            _doseTile(
              label: 'Afternoon',
              checked: afternoon,
              onTap: () => setState(() => afternoon = !afternoon),
            ),
            const SizedBox(height: 14),
            _doseTile(
              label: 'Evening',
              checked: evening,
              onTap: () => setState(() => evening = !evening),
            ),
          ],
        ),
      ),

      // (옵션) 하단 탭 – 기존 페이지들과 톤 맞춤
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
        onTap: (_) {},
      ),
    );
  }

  // one tile
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
            Expanded(
              child: Text(label, style: bigLabel),
            ),
          ],
        ),
      ),
    );
  }

  // custom outlined checkbox in cyan
  Widget _checkIcon(bool checked) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: checked ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF56C7F2), width: 3),
      ),
      child: checked
          ? Icon(Icons.check, size: 18, color: const Color(0xFF56C7F2))
          : const SizedBox.shrink(),
    );
  }
}

/// Simple donut painter
class _DonutPainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0
  final Color color;

  _DonutPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFE5F6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    // background ring
    canvas.drawCircle(center, radius - 8, bgPaint);

    // progress arc (start at -90°)
    final rect = Rect.fromCircle(center: center, radius: radius - 8);
    final start = -90.0 * (3.1415926 / 180);
    final sweep = 2 * 3.1415926 * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      progress != old.progress || color != old.color;
}
