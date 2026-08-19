import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AutoConnectApp());

class AutoConnectApp extends StatelessWidget {
  const AutoConnectApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auto Connect',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF111111),
          scaffoldBackgroundColor: const Color(0xFFF4F4F5),
        ),
        home: const HomePage(),
      );
}

class CatalogDevice {
  final String id, name, brand, emoji, type;
  final List<String> match;
  const CatalogDevice({required this.id, required this.name, required this.brand, required this.emoji, required this.type, required this.match});
}

const catalog = <CatalogDevice>[
  CatalogDevice(id: 'airpods_pro_2', name: 'AirPods Pro 2', brand: 'Apple', emoji: '🎧', type: 'Наушники', match: ['airpods pro', 'airpods']),
  CatalogDevice(id: 'galaxy_buds3_pro', name: 'Galaxy Buds3 Pro', brand: 'Samsung', emoji: '🎧', type: 'Наушники', match: ['galaxy buds3', 'buds3 pro']),
  CatalogDevice(id: 'galaxy_watch7', name: 'Galaxy Watch7', brand: 'Samsung', emoji: '⌚', type: 'Часы', match: ['galaxy watch7', 'watch7']),
  CatalogDevice(id: 'xiaomi_buds5', name: 'Xiaomi Buds 5', brand: 'Xiaomi', emoji: '🎧', type: 'Наушники', match: ['xiaomi buds 5', 'buds 5']),
  CatalogDevice(id: 'xiaomi_watch_s3', name: 'Xiaomi Watch S3', brand: 'Xiaomi', emoji: '⌚', type: 'Часы', match: ['xiaomi watch s3', 'watch s3']),
  CatalogDevice(id: 'oneplus_buds_pro3', name: 'OnePlus Buds Pro 3', brand: 'OnePlus', emoji: '🎧', type: 'Наушники', match: ['oneplus buds pro 3', 'buds pro 3']),
  CatalogDevice(id: 'oneplus_watch2', name: 'OnePlus Watch 2', brand: 'OnePlus', emoji: '⌚', type: 'Часы', match: ['oneplus watch 2', 'watch 2']),
  CatalogDevice(id: 'nothing_ear', name: 'Nothing Ear', brand: 'Nothing', emoji: '🎧', type: 'Наушники', match: ['nothing ear']),
  CatalogDevice(id: 'huawei_freebuds_pro3', name: 'HUAWEI FreeBuds Pro 3', brand: 'HUAWEI', emoji: '🎧', type: 'Наушники', match: ['freebuds pro 3', 'huawei freebuds']),
  CatalogDevice(id: 'sony_wh1000xm5', name: 'Sony WH-1000XM5', brand: 'Sony', emoji: '🎧', type: 'Наушники', match: ['wh-1000xm5', 'wh1000xm5']),
  CatalogDevice(id: 'jbl_tour_pro3', name: 'JBL Tour Pro 3', brand: 'JBL', emoji: '🎧', type: 'Наушники', match: ['jbl tour pro 3', 'tour pro 3']),
  CatalogDevice(id: 'one_more_sonoflow', name: '1MORE SonoFlow Pro', brand: '1MORE', emoji: '🎧', type: 'Наушники', match: ['1more sonoflow', 'sonoflow']),
];

class DeviceInfo {
  final String name, address;
  final int rssi;
  const DeviceInfo({required this.name, required this.address, required this.rssi});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _native = MethodChannel('auto_connect/native');
  StreamSubscription? _events;
  bool _running = false, _overlay = false, _loading = true;
  String _tab = 'catalog', _query = '';
  DeviceInfo? _lastDevice;
  final Set<String> _downloaded = <String>{};
  final Set<String> _enabled = <String>{};

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _events = EventChannel('auto_connect/events').receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final name = (event['name'] ?? 'Bluetooth device').toString();
        final address = (event['address'] ?? '').toString();
        final rssi = int.tryParse('${event['rssi'] ?? -100}') ?? -100;
        if (mounted) setState(() => _lastDevice = DeviceInfo(name: name, address: address, rssi: rssi));
      }
    });
  }

  Future<void> _loadSettings() async {
    try {
      final result = await _native.invokeMethod('getDeviceSettings');
      if (result is Map) {
        _downloaded.addAll((result['downloaded'] as List? ?? const []).map((e) => e.toString()));
        _enabled.addAll((result['enabled'] as List? ?? const []).map((e) => e.toString()));
      }
      final overlay = await _native.invokeMethod<bool>('overlayGranted') ?? false;
      if (mounted) setState(() { _overlay = overlay; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSettings() async => _native.invokeMethod('saveDeviceSettings', {'downloaded': _downloaded.toList(), 'enabled': _enabled.toList()});
  @override void dispose() { _events?.cancel(); super.dispose(); }

  Future<void> _toggle() async {
    try {
      if (!_running) {
        final ok = await _native.invokeMethod<bool>('startScanner') ?? false;
        setState(() => _running = ok);
      } else {
        await _native.invokeMethod('stopScanner');
        setState(() => _running = false);
      }
    } on PlatformException catch (e) { _snack(e.message ?? 'Не удалось запустить сканирование'); }
  }

  Future<void> _overlayPermission() async {
    try {
      final ok = await _native.invokeMethod<bool>('requestOverlay') ?? false;
      setState(() => _overlay = ok);
      if (!ok) _snack('Разрешите «Показывать поверх других приложений» и вернитесь сюда.');
    } catch (_) {}
  }

  Future<void> _connect() async {
    final d = _lastDevice;
    if (d == null) return;
    try {
      await _native.invokeMethod('connect', {'address': d.address});
      _snack('Запрос на подключение отправлен');
    } on PlatformException catch (e) { _snack(e.message ?? 'Не удалось подключить устройство'); }
  }

  Future<void> _download(CatalogDevice device) async {
    setState(() => _downloaded.add(device.id));
    await _saveSettings();
    _snack('${device.name} добавлено в скачанные модели');
  }

  Future<void> _toggleEnabled(CatalogDevice device, bool value) async {
    if (!_downloaded.contains(device.id)) { _snack('Сначала скачайте модель'); return; }
    setState(() { value ? _enabled.add(device.id) : _enabled.remove(device.id); });
    await _saveSettings();
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  CatalogDevice? _matchDevice(String name) {
    final n = name.toLowerCase();
    for (final device in catalog) { if (device.match.any((m) => n.contains(m))) return device; }
    return null;
  }

  List<CatalogDevice> get _visible {
    final q = _query.trim().toLowerCase();
    Iterable<CatalogDevice> source = catalog;
    if (_tab == 'downloaded') source = source.where((d) => _downloaded.contains(d.id));
    if (_tab == 'search') source = source.where((d) => _enabled.contains(d.id));
    if (q.isNotEmpty) source = source.where((d) => '${d.name} ${d.brand}'.toLowerCase().contains(q));
    return source.toList();
  }

  @override
  Widget build(BuildContext context) {
    final detected = _lastDevice;
    final detectedModel = detected == null ? null : _matchDevice(detected.name);
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Connect', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: _overlayPermission, tooltip: 'Popup', icon: Icon(_overlay ? Icons.layers : Icons.layers_clear))]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _statusCard(), const SizedBox(height: 14),
          if (detected != null) _deviceCard(detected, detectedModel),
          const SizedBox(height: 14), _tabs(), const SizedBox(height: 12),
          TextField(onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: _tab == 'search' ? 'Какие устройства искать?' : 'Поиск модели', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          if (_tab == 'search') _searchInfo(),
          ..._visible.map(_modelCard),
          if (_visible.isEmpty) _emptyState(),
        ],
      ),
    );
  }

  Widget _statusCard() => Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Обнаружение рядом', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(_running ? 'Сканирование активно' : 'Сканирование выключено'), const SizedBox(height: 14),
    Row(children: [Expanded(child: FilledButton.icon(onPressed: _toggle, icon: Icon(_running ? Icons.stop : Icons.bluetooth_searching), label: Text(_running ? 'Остановить' : 'Включить'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: _overlayPermission, icon: Icon(_overlay ? Icons.check_circle : Icons.open_in_new), label: Text(_overlay ? 'Popup включён' : 'Включить popup')))])
  ])));

  Widget _tabs() => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
    _tabButton('catalog', 'Все модели', Icons.grid_view_rounded), _tabButton('downloaded', 'Скачанные', Icons.download_done_rounded), _tabButton('search', 'Искать', Icons.radar_rounded),
  ]));

  Widget _tabButton(String value, String title, IconData icon) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(selected: _tab == value, label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(title)]), onSelected: (_) => setState(() { _tab = value; _query = ''; })));

  Widget _searchInfo() => const Card(elevation: 0, child: Padding(padding: EdgeInsets.all(14), child: Row(children: [Icon(Icons.info_outline), SizedBox(width: 10), Expanded(child: Text('В режиме «Искать» popup будет показываться только для выбранных и скачанных моделей.'))])));

  Widget _modelCard(CatalogDevice device) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
    Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.black.withOpacity(.05), borderRadius: BorderRadius.circular(16)), child: Text(device.emoji, style: const TextStyle(fontSize: 31))), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(device.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), Text('${device.brand} • ${device.type}', style: TextStyle(color: Colors.grey.shade700))])),
    if (!_downloaded.contains(device.id)) FilledButton.icon(onPressed: () => _download(device), icon: const Icon(Icons.download, size: 18), label: const Text('Скачать')) else Column(children: [const Text('Скачано', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), Switch(value: _enabled.contains(device.id), onChanged: (v) => _toggleEnabled(device, v))]),
  ])));

  Widget _deviceCard(DeviceInfo d, CatalogDevice? model) => Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
    DeviceArtwork(emoji: model?.emoji ?? '🎧', size: 120), Text(model?.name ?? d.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 4),
    Text('${d.rssi} dBm • ${model == null ? 'модель не добавлена' : (_enabled.contains(model.id) ? 'поиск включён' : 'поиск выключен')}'), const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton(onPressed: _connect, child: const Text('Подключить'))),
  ])));

  Widget _emptyState() => Padding(padding: const EdgeInsets.symmetric(vertical: 38), child: Column(children: [const Icon(Icons.inventory_2_outlined, size: 52), const SizedBox(height: 10), Text(_tab == 'downloaded' ? 'Пока ничего не скачано' : _tab == 'search' ? 'Нет включённых моделей' : 'Модели не найдены', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))]));
}

class DeviceArtwork extends StatefulWidget {
  final String emoji;
  final double size;
  const DeviceArtwork({super.key, required this.emoji, required this.size});
  @override State<DeviceArtwork> createState() => _DeviceArtworkState();
}

class _DeviceArtworkState extends State<DeviceArtwork> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (_, child) => Transform(alignment: Alignment.center, transform: Matrix4.identity()..setEntry(3, 2, .0012)..rotateY((_c.value * 6.283) - 3.1415), child: child), child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)));
}
