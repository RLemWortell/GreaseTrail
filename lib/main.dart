import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/config.dart' as config_data;
import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets/top_bar.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/vehicle_screen.dart';
import 'screens/service_screen.dart';
import 'screens/edit_service_screen.dart';
import 'screens/add_log_screen.dart';
import 'screens/manage_categories_screen.dart';

void main() {
  runApp(const GreaseTrailApp());
}

class GreaseTrailApp extends StatelessWidget {
  const GreaseTrailApp({super.key});

  ThemeData _theme(AppColors c, Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: c.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: c.accent, brightness: brightness),
        splashFactory: NoSplash.splashFactory,
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreaseTrail',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _theme(AppColors.light, Brightness.light),
      darkTheme: _theme(AppColors.dark, Brightness.dark),
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
  final String? returnTo;
  final String? configId;
  final String? vehicleType;
  const AddVehicleRoute({this.returnTo, this.configId, this.vehicleType});
}

class VehicleRoute extends AppRoute {
  final String vehicleId;
  final String? returnTo;
  const VehicleRoute(this.vehicleId, {this.returnTo});
}

class ServiceRoute extends AppRoute {
  final String vehicleId;
  final String packageId;
  final String? returnTo;
  const ServiceRoute({required this.vehicleId, required this.packageId, this.returnTo});
}

class EditServiceRoute extends AppRoute {
  final String vehicleId;
  final String? serviceId;
  final String? returnTo;
  const EditServiceRoute({required this.vehicleId, this.serviceId, this.returnTo});
}

class AddLogRoute extends AppRoute {
  final String vehicleId;
  final String categoryId;
  final String returnTo;
  const AddLogRoute({required this.vehicleId, required this.categoryId, required this.returnTo});
}

class ManageRoute extends AppRoute {
  final String vehicleId;
  final String returnTo;
  const ManageRoute({required this.vehicleId, required this.returnTo});
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Vehicle> _vehicles = [];
  List<config_data.GtConfig> _configs = [];
  bool _ready = false;
  bool _hasLoaded = false;
  AppTab _tab = AppTab.home;
  AppRoute _route = const TabsRoute();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stored = await loadVehicles();
    final configs = await config_data.loadConfigs();
    setState(() {
      _vehicles = (stored != null && stored.isNotEmpty) ? stored : seedDemoData();
      _configs = configs;
      _hasLoaded = true;
      _ready = true;
    });
  }

  void _persistVehicles() {
    if (!_hasLoaded) return;
    saveVehicles(_vehicles);
  }

  void _persistConfigs() {
    if (!_hasLoaded) return;
    config_data.saveConfigs(_configs);
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
    _persistVehicles();
  }

  static String _resolveTabReturnTo(String? value) => (value == 'home' || value == 'log' || value == 'setup') ? value! : 'home';

  void _goToTabOrHome(String? returnTo) {
    setState(() {
      _tab = switch (returnTo) {
        'log' => AppTab.log,
        'setup' => AppTab.setup,
        _ => AppTab.home,
      };
      _route = const TabsRoute();
    });
  }

  void _addLogsBatch(Vehicle vehicle, List<LogEntry> logs, String? returnTo) {
    var maxOdo = vehicle.odometer;
    for (final l in logs) {
      if (l.odometer > maxOdo) maxOdo = l.odometer;
    }
    final updated = vehicle.copyWith(odometer: maxOdo, logs: [...vehicle.logs, ...logs]);
    setState(() {
      _vehicles = _vehicles.map((v) => v.id == updated.id ? updated : v).toList();
      _route = VehicleRoute(vehicle.id, returnTo: _resolveTabReturnTo(returnTo));
    });
    _persistVehicles();
  }

  void _openVehicle(String id, String returnTo) => setState(() => _route = VehicleRoute(id, returnTo: returnTo));

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;

    if (!_ready) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: ColoredBox(color: c.bg),
      );
    }

    final route = _route;
    final showTabs = route is TabsRoute;

    Widget body;
    switch (route) {
      case TabsRoute():
        body = switch (_tab) {
          AppTab.home => HomeScreen(
              vehicles: _vehicles,
              onOpenVehicle: (id) => _openVehicle(id, 'home'),
              onAddVehicle: () => setState(() => _route = const AddVehicleRoute(returnTo: 'home')),
              onOpenCategory: (vehicleId, categoryId) =>
                  setState(() => _route = AddLogRoute(vehicleId: vehicleId, categoryId: categoryId, returnTo: 'home')),
            ),
          AppTab.log => LogScreen(vehicles: _vehicles, onOpenVehicle: (id) => _openVehicle(id, 'log')),
          AppTab.setup => SetupScreen(
              vehicles: _vehicles,
              configs: _configs,
              onConfigsChange: (list) {
                setState(() => _configs = list);
                _persistConfigs();
              },
              onAddVehicle: () => setState(() => _route = const AddVehicleRoute(returnTo: 'setup')),
              onManage: (id) => setState(() => _route = ManageRoute(vehicleId: id, returnTo: 'setup')),
              onCreateFromConfig: (cfg) => setState(() => _route = AddVehicleRoute(
                    returnTo: 'setup',
                    configId: cfg.builtin ? 'default' : cfg.id,
                    vehicleType: cfg.type,
                  )),
            ),
        };
      case AddVehicleRoute(returnTo: final returnTo, configId: final configId, vehicleType: final vehicleType):
        body = AddVehicleScreen(
          configs: _configs,
          initialConfigId: configId,
          initialType: vehicleType,
          onBack: () => _goToTabOrHome(returnTo),
          onSave: (v) {
            setState(() {
              _vehicles = [..._vehicles, v];
              _route = VehicleRoute(v.id, returnTo: returnTo ?? 'home');
            });
            _persistVehicles();
          },
        );
      case VehicleRoute(vehicleId: final id, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        body = vehicle == null
            ? const SizedBox.shrink()
            : VehicleScreen(
                key: ValueKey('vehicle-$id'),
                vehicle: vehicle,
                onBack: () => _goToTabOrHome(returnTo),
                onOpenCategory: (catId) =>
                    setState(() => _route = AddLogRoute(vehicleId: id, categoryId: catId, returnTo: 'vehicle')),
                onManage: () => setState(() => _route = ManageRoute(vehicleId: id, returnTo: 'vehicle')),
                onOpenService: (packageId) =>
                    setState(() => _route = ServiceRoute(vehicleId: id, packageId: packageId, returnTo: returnTo)),
                onAddService: () => setState(() => _route = EditServiceRoute(vehicleId: id, returnTo: returnTo)),
                onUpdateOdo: (val) => _updateVehicle(vehicle.copyWith(odometer: val)),
                onUpdatePhotos: (photos) => _updateVehicle(vehicle.copyWith(photos: photos)),
              );
      case ServiceRoute(vehicleId: final id, packageId: final packageId, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        body = vehicle == null
            ? const SizedBox.shrink()
            : ServiceScreen(
                vehicle: vehicle,
                packageId: packageId,
                onBack: () => setState(() => _route = VehicleRoute(id, returnTo: returnTo)),
                onSave: (logs) => _addLogsBatch(vehicle, logs, returnTo),
              );
      case EditServiceRoute(vehicleId: final id, serviceId: final serviceId, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        body = vehicle == null
            ? const SizedBox.shrink()
            : EditServiceScreen(
                vehicle: vehicle,
                serviceId: serviceId,
                onBack: () => setState(() => _route = returnTo == 'manage'
                    ? ManageRoute(vehicleId: id, returnTo: 'vehicle')
                    : VehicleRoute(id, returnTo: returnTo ?? 'home')),
                onUpdateVehicle: _updateVehicle,
              );
      case AddLogRoute(vehicleId: final id, categoryId: final categoryId, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        final category = vehicle?.categories.where((c) => c.id == categoryId).firstOrNull;
        body = (vehicle == null || category == null)
            ? const SizedBox.shrink()
            : AddLogScreen(
                vehicle: vehicle,
                category: category,
                onBack: () => returnTo == 'home' ? _goToTabOrHome('home') : setState(() => _route = VehicleRoute(id)),
                onSave: (log) => _addLogsBatch(vehicle, [log], returnTo),
              );
      case ManageRoute(vehicleId: final id, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        body = vehicle == null
            ? const SizedBox.shrink()
            : ManageCategoriesScreen(
                key: ValueKey('manage-$id'),
                vehicle: vehicle,
                onBack: () => returnTo == 'setup' ? _goToTabOrHome('setup') : setState(() => _route = VehicleRoute(id)),
                onUpdateVehicle: _updateVehicle,
                onEditService: (serviceId) =>
                    setState(() => _route = EditServiceRoute(vehicleId: id, serviceId: serviceId, returnTo: 'manage')),
                onAddService: () => setState(() => _route = EditServiceRoute(vehicleId: id, returnTo: 'manage')),
                onSaveConfig: (cfg) {
                  setState(() => _configs = [..._configs, cfg]);
                  _persistConfigs();
                },
              );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          top: true,
          bottom: !showTabs,
          child: Column(
            children: [
              Expanded(child: body),
              if (showTabs) AppTabBar(tab: _tab, onChanged: (t) => setState(() => _tab = t)),
            ],
          ),
        ),
      ),
    );
  }
}
