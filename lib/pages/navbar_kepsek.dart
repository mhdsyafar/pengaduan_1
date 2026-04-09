import 'package:flutter/material.dart';
import 'dashboard_kepsek.dart';
import 'statistics_view.dart';
import 'laporan_view.dart';
import 'monitoring_view.dart';
import 'profil_kepsek.dart';

class NavbarKepsek extends StatefulWidget {
  const NavbarKepsek({super.key});

  @override
  State<NavbarKepsek> createState() => _NavbarKepsekState();
}

class _NavbarKepsekState extends State<NavbarKepsek> {
  int _idx = 0;

  static const Color _primary = Color(0xFF7048E8);

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Beranda'),
    _NavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Statistik'),
    _NavItem(Icons.description_rounded, Icons.description_outlined, 'Laporan'),
    _NavItem(Icons.monitor_heart_rounded, Icons.monitor_heart_outlined, 'Monitor'),
    _NavItem(Icons.person_rounded, Icons.person_outlined, 'Profil'),
  ];

  final List<Widget> _pages = const [
    DashboardKepsek(),
    StatisticsView(),
    LaporanView(),
    MonitoringView(),
    ProfilKepsekPage(),
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
            color: _primary.withOpacity(0.10),
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
          color: active ? _primary.withOpacity(0.12) : Colors.transparent,
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
