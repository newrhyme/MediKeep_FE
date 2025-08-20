import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import 'dashboard_page.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  // Colors & styles
  static const bg = Color(0xFFC6F2FF);
  static const navy = Color(0xFF2D4868);
  static const chipOn = Color(0xFF87E3FF);
  static const chipOff = Colors.white;

  final TextEditingController _whatCtrl = TextEditingController();

  // 요일 & 시간대 선택 상태
  final List<String> _days = const ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final Set<int> _selectedDays = {};
  final List<String> _slots = const ['Morning', 'Lunch', 'Evening', 'Night'];
  final Set<int> _selectedSlots = {};

  // ★ 서버 ENUM 매핑
  static const _weekdayEnum = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _slotEnum = ['MORNING', 'LUNCH', 'EVENING', 'NIGHT'];

  bool _showInstructions = false; // "Check dosage instructions" 후 노출
  bool _loading = false;

  @override
  void dispose() {
    _whatCtrl.dispose();
    super.dispose();
  }

  TextStyle get _labelStyle => GoogleFonts.carterOne(
      fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w800);

  InputDecoration _inputDeco() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      hintText: 'Vitamin C',
      hintStyle: GoogleFonts.carterOne(color: navy.withOpacity(.45)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: navy.withOpacity(.25), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: navy, width: 1.6),
      ),
    );
  }

  Widget _dayChip(int idx) {
    final selected = _selectedDays.contains(idx);
    return RawMaterialButton(
      onPressed: () {
        setState(() {
          if (selected) {
            _selectedDays.remove(idx);
          } else {
            _selectedDays.add(idx);
          }
        });
      },
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      fillColor: selected ? chipOn : chipOff,
      elevation: selected ? 2 : 0,
      shape: const CircleBorder(side: BorderSide(color: Color(0x5582A2BE))),
      child: Text(
        _days[idx],
        style: GoogleFonts.carterOne(
          color: navy,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _slotChip(int idx) {
    final selected = _selectedSlots.contains(idx);
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) {
          setState(() {
            selected ? _selectedSlots.remove(idx) : _selectedSlots.add(idx);
          });
        },
        label: Text(
          _slots[idx],
          style: GoogleFonts.carterOne(
            color: navy,
            fontWeight: FontWeight.w900,
          ),
        ),
        selectedColor: chipOn,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0x5582A2BE)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _save() async {
    if (_loading) return;

    final name = _whatCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Enter medication name', style: GoogleFonts.carterOne())),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Select at least one weekday',
                style: GoogleFonts.carterOne())),
      );
      return;
    }
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Select at least one time slot',
                style: GoogleFonts.carterOne())),
      );
      return;
    }

    final weekdays = _selectedDays.map((i) => _weekdayEnum[i]).toList();
    final timeSlots = _selectedSlots.map((i) => _slotEnum[i]).toList();

    setState(() => _loading = true);
    try {
      final res = await ApiClient.postJson(
        "/api/schedules",
        {
          "medicationName": name,
          "medicationType": "MEDICINE", // 필요 시 드롭다운으로 바꿔도 됨
          "weekdays": weekdays,
          "timeSlots": timeSlots,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // 성공 모달
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Saved successfully!',
                      style: GoogleFonts.carterOne(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _showInstructions = true);
                    },
                    child: Text(
                      'Check dosage instructions ⟶',
                      style: GoogleFonts.carterOne(
                        color: navy,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Save failed: ${res.statusCode}',
                  style: GoogleFonts.carterOne())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e', style: GoogleFonts.carterOne())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg, // 상단 배경은 라이트블루 유지
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Medication Schedule',
          style: GoogleFonts.carterOne(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더와 폼 사이 살짝 여백
            const SizedBox(height: 6),

            // 폼 패널(흰 배경 + 위쪽 둥근모서리 + 그림자)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  children: [
                    // What will you take?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('What will you take?', style: _labelStyle),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _whatCtrl,
                            style: GoogleFonts.carterOne(
                                color: navy, fontSize: 16),
                            decoration: _inputDeco(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      thickness: 1,
                      height: 28,
                      color: navy.withOpacity(.15),
                    ),

                    // 요일
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_days.length, _dayChip),
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      thickness: 1,
                      height: 28,
                      color: navy.withOpacity(.15),
                    ),

                    // 시간대
                    Wrap(children: List.generate(_slots.length, _slotChip)),
                    const SizedBox(height: 24),

                    // SAVE 버튼
                    Center(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF87E3FF),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: GoogleFonts.carterOne(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        child: const Text('SAVE'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Instructions (저장 후 노출)
                    if (_showInstructions) ...[
                      Divider(
                        thickness: 1,
                        height: 28,
                        color: navy.withOpacity(.15),
                      ),
                      Text(
                        'Instructions',
                        style: GoogleFonts.carterOne(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 180,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x33000000)),
                        ),
                        child: Text(
                          'Dosage info will appear here for "${_whatCtrl.text.isEmpty ? 'your supplement' : _whatCtrl.text}".',
                          style:
                              GoogleFonts.carterOne(fontSize: 14, color: navy),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 탭
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
          if (i == 1) return;
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              break;
          }
        },
      ),
    );
  }
}
