import 'package:flutter/material.dart';
import 'dashboard_tu.dart';
import 'data_pengaduan.dart';
import 'kelola_pengadu.dart';
import 'kelola_petugas.dart';
import 'profil_tu.dart';

class NavbarTU extends StatefulWidget {
  const NavbarTU({super.key});

  @override
  State<NavbarTU> createState() => _NavbarTUState();
}

class _NavbarTUState extends State<NavbarTU> {
  int _idx = 0;

  static const Color _primary = Color(0xFF3B5BDB);

  void _navigateTo(String screen) {
    final map = {'pengaduan': 1, 'pengadu': 2, 'petugas': 3, 'profil': 4};
    if (map.containsKey(screen)) setState(() => _idx = map[screen]!);
  }

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(Icons.inbox_rounded, Icons.inbox_outlined, 'Pengaduan'),
    _NavItem(Icons.people_rounded, Icons.people_outlined, 'Orang Tua'),
    _NavItem(Icons.badge_rounded, Icons.badge_outlined, 'Petugas'),
    _NavItem(Icons.person_rounded, Icons.person_outlined, 'Profil'),
  ];

  List<Widget> get _pages => [
    DashboardTU(onNavigate: _navigateTo),
    const DataPengaduan(),
    const KelolaPengaduPage(),
    const KelolaPetugasPage(),
    const ProfilTUPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, _buildItem),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i) {
    final active = _idx == i;
    final item = _navItems[i];
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? item.activeIcon : item.icon,
              size: 22,
              color: active ? _primary : Colors.grey.shade400,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? _primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}
