import 'package:flutter/material.dart';

import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets/top_bar.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/vehicle_screen.dart';
import 'screens/add_log_screen.dart';
import 'screens/manage_categories_screen.dart';

void main() {
  runApp(const GreaseTrailApp());
}

class GreaseTrailApp extends StatelessWidget {
  const GreaseTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreaseTrail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent, brightness: Brightness.light),
        splashFactory: NoSplash.splashFactory,
      ),
      home: const RootPage(),
    );
  }
}

sealed class AppRoute {
  const AppRoute();
}

class TabsRoute extends AppRoute {
  const TabsRoute();
}

class AddVehicleRoute extends AppRoute {
  const AddVehicleRoute();
}

class VehicleRoute extends AppRoute {
  final String vehicleId;
  const VehicleRoute(this.vehicleId);
}

class AddLogRoute extends AppRoute {
  final String vehicleId;
  final String categoryId;
  final String back;
  const AddLogRoute({required this.vehicleId, required this.categoryId, required this.back});
}

class ManageRoute extends AppRoute {
  final String vehicleId;
  final String back;
  const ManageRoute({required this.vehicleId, required this.back});
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Vehicle> _vehicles = [];
  bool _ready = false;
  bool _hasLoaded = false;
  AppTab _tab = AppTab.garage;
  AppRoute _route = const TabsRoute();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stored = await loadVehicles();
    setState(() {
      _vehicles = (stored != null && stored.isNotEmpty) ? stored : seedDemoData();
      _hasLoaded = true;
      _ready = true;
    });
  }

  void _persist() {
    if (!_hasLoaded) return;
    saveVehicles(_vehicles);
  }

  Vehicle? _findVehicle(String id) {
    for (final v in _vehicles) {
      if (v.id == id) return v;
    }
    return null;
  }

  void _updateVehicle(Vehicle updated) {
    setState(() {
      _vehicles = _vehicles.map((v) => v.id == updated.id ? updated : v).toList();
    });
    _persist();
  }

  void _addLog(Vehicle vehicle, LogEntry log) {
    final updated = vehicle.copyWith(
      odometer: log.odometer > vehicle.odometer ? log.odometer : vehicle.odometer,
      logs: [...vehicle.logs, log],
    );
    setState(() {
      _vehicles = _vehicles.map((v) => v.id == updated.id ? updated : v).toList();
      _route = VehicleRoute(vehicle.id);
    });
    _persist();
  }

  void _openVehicle(String id) => setState(() => _route = VehicleRoute(id));
  void _addVehicle() => setState(() => _route = const AddVehicleRoute());

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const ColoredBox(color: AppColors.bg);
    }

    final route = _route;
    final showTabs = route is TabsRoute;

    Widget body;
    switch (route) {
      case TabsRoute():
        body = switch (_tab) {
          AppTab.garage => HomeScreen(
              vehicles: _vehicles,
              onOpenVehicle: _openVehicle,
              onAddVehicle: _addVehicle,
              onOpenCategory: (vehicleId, categoryId) => setState(
                () => _route = AddLogRoute(vehicleId: vehicleId, categoryId: categoryId, back: 'tabs'),
              ),
            ),
          AppTab.log => LogScreen(vehicles: _vehicles, onOpenVehicle: _openVehicle),
          AppTab.setup => SetupScreen(
              vehicles: _vehicles,
              onAddVehicle: _addVehicle,
              onManageVehicle: (id) => setState(() => _route = ManageRoute(vehicleId: id, back: 'tabs')),
            ),
        };
      case AddVehicleRoute():
        body = AddVehicleScreen(
          onBack: () => setState(() => _route = const TabsRoute()),
          onSave: (v) {
            setState(() {
              _vehicles = [..._vehicles, v];
              _route = VehicleRoute(v.id);
            });
            _persist();
          },
        );
      case VehicleRoute(vehicleId: final id):
        final vehicle = _findVehicle(id);
        body = vehicle == null
            ? const SizedBox.shrink()
            : VehicleScreen(
                key: ValueKey('vehicle-$id'),
                vehicle: vehicle,
                onBack: () => setState(() => _route = const TabsRoute()),
                onOpenCategory: (catId) =>
                    setState(() => _route = AddLogRoute(vehicleId: id, categoryId: catId, back: 'vehicle')),
                onManage: () => setState(() => _route = ManageRoute(vehicleId: id, back: 'vehicle')),
                onUpdateOdo: (val) => _updateVehicle(vehicle.copyWith(odometer: val)),
              );
      case AddLogRoute(vehicleId: final vId, categoryId: final catId, back: final back):
        final vehicle = _findVehicle(vId);
        final category = vehicle?.categories.where((c) => c.id == catId).firstOrNull;
        body = (vehicle == null || category == null)
            ? const SizedBox.shrink()
            : AddLogScreen(
                vehicle: vehicle,
                category: category,
                onBack: () => setState(() => _route = back == 'tabs' ? const TabsRoute() : VehicleRoute(vId)),
                onSave: (log) => _addLog(vehicle, log),
              );
      case ManageRoute(vehicleId: final vId, back: final back):
        final vehicle = _findVehicle(vId);
        body = vehicle == null
            ? const SizedBox.shrink()
            : ManageCategoriesScreen(
                key: ValueKey('manage-$vId'),
                vehicle: vehicle,
                onBack: () => setState(() => _route = back == 'tabs' ? const TabsRoute() : VehicleRoute(vId)),
                onUpdateVehicle: _updateVehicle,
              );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (showTabs) AppTabBar(tab: _tab, onChanged: (t) => setState(() => _tab = t)),
          ],
        ),
      ),
    );
  }
}
