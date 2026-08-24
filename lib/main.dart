import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/config.dart' as config_data;
import 'data/photos.dart';
import 'models.dart';
import 'storage.dart';
import 'theme.dart';
import 'widgets/screen_transition.dart';
import 'widgets/splash_screen.dart';
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
import 'screens/edit_config_screen.dart';

void main() {
  runApp(const GreaseTrailApp());
}

class GreaseTrailApp extends StatefulWidget {
  const GreaseTrailApp({super.key});

  @override
  State<GreaseTrailApp> createState() => _GreaseTrailAppState();
}

class _GreaseTrailAppState extends State<GreaseTrailApp> {
  Color? _accent;

  @override
  void initState() {
    super.initState();
    loadAccentColor().then((value) {
      if (mounted && value != null) setState(() => _accent = Color(value));
    });
  }

  void _setAccent(Color? color) {
    setState(() => _accent = color);
    saveAccentColor(color?.toARGB32());
  }

  ThemeData _theme(AppColors c, Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: c.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: _accent ?? c.accent, brightness: brightness),
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
      builder: (context, child) => AccentScope(accent: _accent, child: child!),
      home: RootPage(accent: _accent, onAccentChange: _setAccent),
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

class ConfigRoute extends AppRoute {
  final String configId;
  const ConfigRoute(this.configId);
}

/// Where a route's back action lands, and which tab should be selected if
/// that destination is the tabs root.
class _BackTarget {
  final AppRoute route;
  final AppTab? tab;
  const _BackTarget(this.route, {this.tab});
}

class RootPage extends StatefulWidget {
  final Color? accent;
  final ValueChanged<Color?> onAccentChange;

  const RootPage({super.key, required this.accent, required this.onAccentChange});

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
  bool _lastNavWasBack = false;

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

  config_data.GtConfig? _findConfig(String id) {
    for (final cfg in config_data.builtinConfigs()) {
      if (cfg.id == id) return cfg;
    }
    for (final cfg in _configs) {
      if (cfg.id == id) return cfg;
    }
    return null;
  }

  void _updateConfig(config_data.GtConfig updated) {
    setState(() => _configs = _configs.map((c) => c.id == updated.id ? updated : c).toList());
    _persistConfigs();
  }

  void _duplicateConfig(config_data.GtConfig cfg) {
    final copy = config_data.duplicateConfig(cfg);
    setState(() => _configs = [..._configs, copy]);
    _persistConfigs();
    _navigate(ConfigRoute(copy.id));
  }

  void _deleteConfig(String id) {
    setState(() => _configs = _configs.where((c) => c.id != id).toList());
    _persistConfigs();
    _goBack();
  }

  static String _resolveTabReturnTo(String? value) => (value == 'home' || value == 'log' || value == 'setup') ? value! : 'home';

  static AppTab _tabFor(String? returnTo) => switch (returnTo) {
        'log' => AppTab.log,
        'setup' => AppTab.setup,
        _ => AppTab.home,
      };

  /// Pushes forward to a new screen (slides in from the right).
  void _navigate(AppRoute route) {
    _lastNavWasBack = false;
    setState(() => _route = route);
  }

  /// Where the current route's back action leads, or null if there is none
  /// (i.e. we're already at the tabs root).
  _BackTarget? _backTargetFor(AppRoute route) {
    switch (route) {
      case TabsRoute():
        return null;
      case AddVehicleRoute(returnTo: final returnTo):
        return _BackTarget(const TabsRoute(), tab: _tabFor(returnTo));
      case VehicleRoute(returnTo: final returnTo):
        return _BackTarget(const TabsRoute(), tab: _tabFor(returnTo));
      case ServiceRoute(vehicleId: final id, returnTo: final returnTo):
        return _BackTarget(VehicleRoute(id, returnTo: returnTo));
      case EditServiceRoute(vehicleId: final id, returnTo: final returnTo):
        return returnTo == 'manage'
            ? _BackTarget(ManageRoute(vehicleId: id, returnTo: 'vehicle'))
            : _BackTarget(VehicleRoute(id, returnTo: returnTo ?? 'home'));
      case AddLogRoute(vehicleId: final id, returnTo: final returnTo):
        return returnTo == 'home' ? _BackTarget(const TabsRoute(), tab: AppTab.home) : _BackTarget(VehicleRoute(id));
      case ManageRoute(vehicleId: final id, returnTo: final returnTo):
        return returnTo == 'setup' ? _BackTarget(const TabsRoute(), tab: AppTab.setup) : _BackTarget(VehicleRoute(id));
      case ConfigRoute():
        return _BackTarget(const TabsRoute(), tab: AppTab.setup);
    }
  }

  /// Pops back to whatever `_backTargetFor(_route)` resolves to (slides out
  /// to the right, revealing the destination underneath). No-op at the root.
  void _goBack() {
    final target = _backTargetFor(_route);
    if (target == null) return;
    _lastNavWasBack = true;
    setState(() {
      if (target.tab != null) _tab = target.tab!;
      _route = target.route;
    });
  }

  void _deleteVehicle(String id, String returnTo) {
    final vehicle = _findVehicle(id);
    _lastNavWasBack = true;
    setState(() {
      _vehicles = _vehicles.where((v) => v.id != id).toList();
      _tab = _tabFor(returnTo);
      _route = const TabsRoute();
    });
    _persistVehicles();
    if (vehicle != null) {
      for (final uri in vehicle.photos) {
        removePhotoFile(uri);
      }
      for (final log in vehicle.logs) {
        for (final uri in log.photos) {
          removePhotoFile(uri);
        }
      }
    }
  }

  void _addLogsBatch(Vehicle vehicle, List<LogEntry> logs, String? returnTo) {
    var maxOdo = vehicle.odometer;
    for (final l in logs) {
      if (l.odometer > maxOdo) maxOdo = l.odometer;
    }
    final updated = vehicle.copyWith(odometer: maxOdo, logs: [...vehicle.logs, ...logs]);
    _lastNavWasBack = true;
    setState(() {
      _vehicles = _vehicles.map((v) => v.id == updated.id ? updated : v).toList();
      _route = VehicleRoute(vehicle.id, returnTo: _resolveTabReturnTo(returnTo));
    });
    _persistVehicles();
  }

  /// Builds the full screen (including its own SafeArea, and the tab bar for
  /// the tabs root) for [route]/[tab]. Pure given the current app state, so
  /// it can be used both for what's on screen now and for the edge-swipe's
  /// "reveal what's behind" preview.
  Widget _buildScreen(AppRoute route, AppTab tab) {
    switch (route) {
      case TabsRoute():
        final tabContent = switch (tab) {
          AppTab.home => HomeScreen(
              vehicles: _vehicles,
              onOpenVehicle: (id) => _navigate(VehicleRoute(id, returnTo: 'home')),
              onAddVehicle: () => _navigate(const AddVehicleRoute(returnTo: 'home')),
              onOpenCategory: (vehicleId, categoryId) =>
                  _navigate(AddLogRoute(vehicleId: vehicleId, categoryId: categoryId, returnTo: 'home')),
            ),
          AppTab.log => LogScreen(vehicles: _vehicles, onOpenVehicle: (id) => _navigate(VehicleRoute(id, returnTo: 'log'))),
          AppTab.setup => SetupScreen(
              vehicles: _vehicles,
              configs: _configs,
              onConfigsChange: (list) {
                setState(() => _configs = list);
                _persistConfigs();
              },
              onAddVehicle: () => _navigate(const AddVehicleRoute(returnTo: 'setup')),
              onManage: (id) => _navigate(ManageRoute(vehicleId: id, returnTo: 'setup')),
              onCreateFromConfig: (cfg) => _navigate(AddVehicleRoute(
                    returnTo: 'setup',
                    configId: cfg.builtin ? 'default' : cfg.id,
                    vehicleType: cfg.type,
                  )),
              onOpenConfig: (id) => _navigate(ConfigRoute(id)),
              accent: widget.accent,
              onAccentChange: widget.onAccentChange,
            ),
        };
        return SafeArea(
          key: const ValueKey('tabs'),
          bottom: false,
          child: Column(
            children: [
              Expanded(child: tabContent),
              AppTabBar(tab: tab, onChanged: (t) => setState(() => _tab = t)),
            ],
          ),
        );

      case AddVehicleRoute(returnTo: final returnTo, configId: final configId, vehicleType: final vehicleType):
        return SafeArea(
          key: const ValueKey('addVehicle'),
          child: AddVehicleScreen(
            configs: _configs,
            initialConfigId: configId,
            initialType: vehicleType,
            onBack: _goBack,
            onSave: (v) {
              _lastNavWasBack = false;
              setState(() {
                _vehicles = [..._vehicles, v];
                _route = VehicleRoute(v.id, returnTo: returnTo ?? 'home');
              });
              _persistVehicles();
            },
          ),
        );

      case VehicleRoute(vehicleId: final id, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        return SafeArea(
          key: ValueKey('vehicle-$id'),
          child: vehicle == null
              ? const SizedBox.shrink()
              : VehicleScreen(
                  vehicle: vehicle,
                  onBack: _goBack,
                  onOpenCategory: (catId) => _navigate(AddLogRoute(vehicleId: id, categoryId: catId, returnTo: 'vehicle')),
                  onManage: () => _navigate(ManageRoute(vehicleId: id, returnTo: 'vehicle')),
                  onOpenService: (packageId) => _navigate(ServiceRoute(vehicleId: id, packageId: packageId, returnTo: returnTo)),
                  onAddService: () => _navigate(EditServiceRoute(vehicleId: id, returnTo: returnTo)),
                  onUpdateOdo: (val) => _updateVehicle(vehicle.copyWith(odometer: val)),
                  onUpdatePhotos: (photos) => _updateVehicle(vehicle.copyWith(photos: photos)),
                ),
        );

      case ServiceRoute(vehicleId: final id, packageId: final packageId, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        return SafeArea(
          key: ValueKey('service-$id-$packageId'),
          child: vehicle == null
              ? const SizedBox.shrink()
              : ServiceScreen(
                  vehicle: vehicle,
                  packageId: packageId,
                  onBack: _goBack,
                  onSave: (logs) => _addLogsBatch(vehicle, logs, returnTo),
                ),
        );

      case EditServiceRoute(vehicleId: final id, serviceId: final serviceId, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        return SafeArea(
          key: ValueKey('editService-$id-${serviceId ?? "new"}-$returnTo'),
          child: vehicle == null
              ? const SizedBox.shrink()
              : EditServiceScreen(
                  vehicle: vehicle,
                  serviceId: serviceId,
                  onBack: _goBack,
                  onUpdateVehicle: _updateVehicle,
                ),
        );

      case AddLogRoute(vehicleId: final id, categoryId: final categoryId, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        final category = vehicle?.categories.where((c) => c.id == categoryId).firstOrNull;
        return SafeArea(
          key: ValueKey('addLog-$id-$categoryId-$returnTo'),
          child: (vehicle == null || category == null)
              ? const SizedBox.shrink()
              : AddLogScreen(
                  vehicle: vehicle,
                  category: category,
                  onBack: _goBack,
                  onSave: (log) => _addLogsBatch(vehicle, [log], returnTo),
                ),
        );

      case ManageRoute(vehicleId: final id, returnTo: final returnTo):
        final vehicle = _findVehicle(id);
        return SafeArea(
          key: ValueKey('manage-$id-$returnTo'),
          child: vehicle == null
              ? const SizedBox.shrink()
              : ManageCategoriesScreen(
                  vehicle: vehicle,
                  onBack: _goBack,
                  onUpdateVehicle: _updateVehicle,
                  onEditService: (serviceId) =>
                      _navigate(EditServiceRoute(vehicleId: id, serviceId: serviceId, returnTo: 'manage')),
                  onAddService: () => _navigate(EditServiceRoute(vehicleId: id, returnTo: 'manage')),
                  onDeleteVehicle: () => _deleteVehicle(id, returnTo),
                  onSaveConfig: (cfg) {
                    setState(() => _configs = [..._configs, cfg]);
                    _persistConfigs();
                  },
                ),
        );

      case ConfigRoute(configId: final id):
        final cfg = _findConfig(id);
        return SafeArea(
          key: ValueKey('config-$id'),
          child: cfg == null
              ? const SizedBox.shrink()
              : EditConfigScreen(
                  config: cfg,
                  onBack: _goBack,
                  onUpdate: _updateConfig,
                  onDuplicate: () => _duplicateConfig(cfg),
                  onCreateVehicle: () => _navigate(AddVehicleRoute(
                        returnTo: 'setup',
                        configId: cfg.builtin ? 'default' : cfg.id,
                        vehicleType: cfg.type,
                      )),
                  onExport: () => config_data.exportConfig(cfg, context),
                  onDelete: cfg.builtin ? null : () => _deleteConfig(cfg.id),
                ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overlayStyle = brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    if (!_ready) {
      return AnnotatedRegion<SystemUiOverlayStyle>(value: overlayStyle, child: const SplashScreen());
    }

    final backTarget = _backTargetFor(_route);
    final current = _buildScreen(_route, _tab);
    final behind = backTarget != null ? _buildScreen(backTarget.route, backTarget.tab ?? _tab) : null;
    final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: c.bg,
        body: ScreenTransition(
          onBack: backTarget != null ? _goBack : null,
          behind: behind,
          isBack: _lastNavWasBack,
          child: current,
        ),
      ),
    );
  }
}
