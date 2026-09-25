import 'package:flutter/material.dart';

import 'appointments_screen.dart';
import 'pet_care_screen.dart';
import 'records_screen.dart';
import 'settings_screen.dart';
import 'home_dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _navigationGreen = Color(0xff063d32);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeDashboardView(onMenu: () => _scaffoldKey.currentState?.openDrawer()),
      RecordsScreen(embedded: true, onBack: () => _selectTab(0)),
      const PetCareScreen(embedded: true),
      const AppointmentsScreen(embedded: true),
      SettingsScreen(embedded: true, onBack: () => _selectTab(0)),
    ];
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/logo.png', width: 72, height: 72),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Veterinaria EIVET',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 22),
              for (final entry in const [
                (Icons.home_outlined, 'Inicio'),
                (Icons.pets_outlined, 'Mascotas'),
                (Icons.health_and_safety_outlined, 'Cuidados'),
                (Icons.event_note_outlined, 'Citas'),
                (Icons.person_outline, 'Perfil'),
              ].indexed)
                ListTile(
                  leading: Icon(entry.$2.$1, color: _navigationGreen),
                  title: Text(entry.$2.$2),
                  onTap: () {
                    Navigator.pop(context);
                    _selectTab(entry.$1);
                  },
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: ColoredBox(
        color: _navigationGreen,
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            height: 72,
            backgroundColor: _navigationGreen,
            indicatorColor: const Color(0xffd7fab3),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelTextStyle: WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? const Color(0xffe4ffc5)
                    : const Color(0xffd5e6df),
                fontSize: 10,
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
            onDestinationSelected: _selectTab,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.home_rounded, color: _navigationGreen),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.pets_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.pets_rounded, color: _navigationGreen),
                label: 'Mascotas',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white,
                ),
                selectedIcon: Icon(
                  Icons.health_and_safety,
                  color: _navigationGreen,
                ),
                label: 'Cuidados',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.event_note, color: _navigationGreen),
                label: 'Citas',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.white),
                selectedIcon: Icon(Icons.person, color: _navigationGreen),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
