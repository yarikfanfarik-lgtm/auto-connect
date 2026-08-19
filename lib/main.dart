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
  final int year;
  final List<String> match;
  const CatalogDevice({
    required this.id,
    required this.name,
    required this.brand,
    required this.emoji,
    required this.type,
    required this.year,
    required this.match,
  });
}

const catalog = <CatalogDevice>[
  CatalogDevice(id: 'sony_mdr_1000x', name: 'Sony MDR-1000X', brand: 'Sony', emoji: '🎧', type: 'Over-ear', year: 2016, match: ['mdr-1000x', '1000x']),
  CatalogDevice(id: 'sony_wh_1000xm2', name: 'Sony WH-1000XM2', brand: 'Sony', emoji: '🎧', type: 'Over-ear', year: 2017, match: ['wh-1000xm2', 'wh1000xm2']),
  CatalogDevice(id: 'sony_wh_1000xm3', name: 'Sony WH-1000XM3', brand: 'Sony', emoji: '🎧', type: 'Over-ear', year: 2018, match: ['wh-1000xm3', 'wh1000xm3']),
  CatalogDevice(id: 'sony_wh_1000xm4', name: 'Sony WH-1000XM4', brand: 'Sony', emoji: '🎧', type: 'Over-ear', year: 2020, match: ['wh-1000xm4', 'wh1000xm4']),
  CatalogDevice(id: 'sony_wh_1000xm5', name: 'Sony WH-1000XM5', brand: 'Sony', emoji: '🎧', type: 'Over-ear', year: 2022, match: ['wh-1000xm5', 'wh1000xm5']),
  CatalogDevice(id: 'sony_wh_1000xm6', name: 'Sony WH-1000XM6', brand: 'Sony', emoji: '🎧', type: 'Over-ear', year: 2026, match: ['wh-1000xm6', 'wh1000xm6']),
  CatalogDevice(id: 'sony_wf_1000xm3', name: 'Sony WF-1000XM3', brand: 'Sony', emoji: '🎧', type: 'TWS', year: 2019, match: ['wf-1000xm3', 'wf1000xm3']),
  CatalogDevice(id: 'sony_wf_1000xm4', name: 'Sony WF-1000XM4', brand: 'Sony', emoji: '🎧', type: 'TWS', year: 2021, match: ['wf-1000xm4', 'wf1000xm4']),
  CatalogDevice(id: 'sony_wf_1000xm5', name: 'Sony WF-1000XM5', brand: 'Sony', emoji: '🎧', type: 'TWS', year: 2023, match: ['wf-1000xm5', 'wf1000xm5']),
  CatalogDevice(id: 'sony_wf_1000xm6', name: 'Sony WF-1000XM6', brand: 'Sony', emoji: '🎧', type: 'TWS', year: 2026, match: ['wf-1000xm6', 'wf1000xm6']),
  CatalogDevice(id: 'bose_qc35', name: 'Bose QuietComfort 35', brand: 'Bose', emoji: '🎧', type: 'Over-ear', year: 2016, match: ['quietcomfort 35', 'qc35']),
  CatalogDevice(id: 'bose_qc35_ii', name: 'Bose QuietComfort 35 II', brand: 'Bose', emoji: '🎧', type: 'Over-ear', year: 2017, match: ['quietcomfort 35 ii', 'qc35 ii']),
  CatalogDevice(id: 'bose_nc700', name: 'Bose Noise Cancelling Headphones 700', brand: 'Bose', emoji: '🎧', type: 'Over-ear', year: 2019, match: ['headphones 700', 'nc700']),
  CatalogDevice(id: 'bose_qc45', name: 'Bose QuietComfort 45', brand: 'Bose', emoji: '🎧', type: 'Over-ear', year: 2021, match: ['quietcomfort 45', 'qc45']),
  CatalogDevice(id: 'bose_qc_ultra', name: 'Bose QuietComfort Ultra Headphones', brand: 'Bose', emoji: '🎧', type: 'Over-ear', year: 2023, match: ['quietcomfort ultra', 'qc ultra']),
  CatalogDevice(id: 'bose_qc_ultra_2', name: 'Bose QuietComfort Ultra 2nd Gen', brand: 'Bose', emoji: '🎧', type: 'Over-ear', year: 2025, match: ['quietcomfort ultra 2', 'qc ultra 2']),
  CatalogDevice(id: 'airpods_2', name: 'AirPods 2', brand: 'Apple', emoji: '🎧', type: 'TWS', year: 2019, match: ['airpods 2', 'airpods']),
  CatalogDevice(id: 'airpods_3', name: 'AirPods 3', brand: 'Apple', emoji: '🎧', type: 'TWS', year: 2021, match: ['airpods 3']),
  CatalogDevice(id: 'airpods_pro', name: 'AirPods Pro', brand: 'Apple', emoji: '🎧', type: 'TWS', year: 2019, match: ['airpods pro']),
  CatalogDevice(id: 'airpods_pro_2', name: 'AirPods Pro 2', brand: 'Apple', emoji: '🎧', type: 'TWS', year: 2022, match: ['airpods pro 2']),
  CatalogDevice(id: 'airpods_4', name: 'AirPods 4', brand: 'Apple', emoji: '🎧', type: 'TWS', year: 2024, match: ['airpods 4']),
  CatalogDevice(id: 'airpods_max', name: 'AirPods Max', brand: 'Apple', emoji: '🎧', type: 'Over-ear', year: 2020, match: ['airpods max']),
  CatalogDevice(id: 'beats_studio3', name: 'Beats Studio3 Wireless', brand: 'Beats', emoji: '🎧', type: 'Over-ear', year: 2017, match: ['studio3', 'beats studio3']),
  CatalogDevice(id: 'beats_solo3', name: 'Beats Solo3 Wireless', brand: 'Beats', emoji: '🎧', type: 'On-ear', year: 2016, match: ['solo3', 'beats solo3']),
  CatalogDevice(id: 'beats_powerbeats3', name: 'Beats Powerbeats3', brand: 'Beats', emoji: '🎧', type: 'TWS', year: 2016, match: ['powerbeats3']),
  CatalogDevice(id: 'beats_powerbeats_pro', name: 'Beats Powerbeats Pro', brand: 'Beats', emoji: '🎧', type: 'TWS', year: 2019, match: ['powerbeats pro']),
  CatalogDevice(id: 'beats_fit_pro', name: 'Beats Fit Pro', brand: 'Beats', emoji: '🎧', type: 'TWS', year: 2021, match: ['beats fit pro', 'fit pro']),
  CatalogDevice(id: 'beats_studio_buds', name: 'Beats Studio Buds', brand: 'Beats', emoji: '🎧', type: 'TWS', year: 2021, match: ['studio buds']),
  CatalogDevice(id: 'beats_studio_buds_plus', name: 'Beats Studio Buds +', brand: 'Beats', emoji: '🎧', type: 'TWS', year: 2023, match: ['studio buds +', 'studio buds plus']),
  CatalogDevice(id: 'beats_studio_pro', name: 'Beats Studio Pro', brand: 'Beats', emoji: '🎧', type: 'Over-ear', year: 2023, match: ['studio pro', 'beats studio pro']),
  CatalogDevice(id: 'beats_solo4', name: 'Beats Solo 4', brand: 'Beats', emoji: '🎧', type: 'On-ear', year: 2024, match: ['solo 4', 'beats solo 4']),
  CatalogDevice(id: 'beats_powerbeats_pro2', name: 'Beats Powerbeats Pro 2', brand: 'Beats', emoji: '🎧', type: 'TWS', year: 2025, match: ['powerbeats pro 2']),
  CatalogDevice(id: 'sennheiser_pxc550', name: 'Sennheiser PXC 550', brand: 'Sennheiser', emoji: '🎧', type: 'Over-ear', year: 2016, match: ['pxc 550']),
  CatalogDevice(id: 'sennheiser_momentum3', name: 'Sennheiser Momentum 3 Wireless', brand: 'Sennheiser', emoji: '🎧', type: 'Over-ear', year: 2019, match: ['momentum 3']),
  CatalogDevice(id: 'sennheiser_momentum4', name: 'Sennheiser Momentum 4 Wireless', brand: 'Sennheiser', emoji: '🎧', type: 'Over-ear', year: 2022, match: ['momentum 4']),
  CatalogDevice(id: 'sennheiser_momentum5', name: 'Sennheiser Momentum 5 Wireless', brand: 'Sennheiser', emoji: '🎧', type: 'Over-ear', year: 2026, match: ['momentum 5']),
  CatalogDevice(id: 'jbl_live650', name: 'JBL Live 650BTNC', brand: 'JBL', emoji: '🎧', type: 'Over-ear', year: 2019, match: ['live 650btnc', 'jbl live 650']),
  CatalogDevice(id: 'jbl_tune660', name: 'JBL Tune 660NC', brand: 'JBL', emoji: '🎧', type: 'On-ear', year: 2021, match: ['tune 660nc', 'jbl tune 660']),
  CatalogDevice(id: 'jbl_tour_pro2', name: 'JBL Tour Pro 2', brand: 'JBL', emoji: '🎧', type: 'TWS', year: 2022, match: ['tour pro 2']),
  CatalogDevice(id: 'jbl_tour_pro3', name: 'JBL Tour Pro 3', brand: 'JBL', emoji: '🎧', type: 'TWS', year: 2024, match: ['tour pro 3']),
  CatalogDevice(id: 'jbl_live_buds3', name: 'JBL Live Buds 3', brand: 'JBL', emoji: '🎧', type: 'TWS', year: 2024, match: ['live buds 3']),
  CatalogDevice(id: 'galaxy_buds', name: 'Samsung Galaxy Buds', brand: 'Samsung', emoji: '🎧', type: 'TWS', year: 2019, match: ['galaxy buds']),
  CatalogDevice(id: 'galaxy_buds_pro', name: 'Samsung Galaxy Buds Pro', brand: 'Samsung', emoji: '🎧', type: 'TWS', year: 2021, match: ['galaxy buds pro']),
  CatalogDevice(id: 'galaxy_buds2_pro', name: 'Samsung Galaxy Buds2 Pro', brand: 'Samsung', emoji: '🎧', type: 'TWS', year: 2022, match: ['galaxy buds2 pro', 'buds2 pro']),
  CatalogDevice(id: 'galaxy_buds3_pro', name: 'Samsung Galaxy Buds3 Pro', brand: 'Samsung', emoji: '🎧', type: 'TWS', year: 2024, match: ['galaxy buds3 pro', 'buds3 pro']),
  CatalogDevice(id: 'galaxy_buds4', name: 'Samsung Galaxy Buds4', brand: 'Samsung', emoji: '🎧', type: 'TWS', year: 2026, match: ['galaxy buds4', 'buds4']),
  CatalogDevice(id: 'galaxy_buds4_pro', name: 'Samsung Galaxy Buds4 Pro', brand: 'Samsung', emoji: '🎧', type: 'TWS', year: 2026, match: ['galaxy buds4 pro', 'buds4 pro']),
  CatalogDevice(id: 'xiaomi_air2', name: 'Xiaomi Air 2', brand: 'Xiaomi', emoji: '🎧', type: 'TWS', year: 2019, match: ['xiaomi air 2', 'air 2']),
  CatalogDevice(id: 'xiaomi_buds3_pro', name: 'Xiaomi Buds 3 Pro', brand: 'Xiaomi', emoji: '🎧', type: 'TWS', year: 2021, match: ['buds 3 pro', 'xiaomi buds 3']),
  CatalogDevice(id: 'xiaomi_buds4_pro', name: 'Xiaomi Buds 4 Pro', brand: 'Xiaomi', emoji: '🎧', type: 'TWS', year: 2022, match: ['buds 4 pro', 'xiaomi buds 4']),
  CatalogDevice(id: 'xiaomi_buds5', name: 'Xiaomi Buds 5', brand: 'Xiaomi', emoji: '🎧', type: 'TWS', year: 2024, match: ['xiaomi buds 5', 'buds 5']),
  CatalogDevice(id: 'oneplus_buds', name: 'OnePlus Buds', brand: 'OnePlus', emoji: '🎧', type: 'TWS', year: 2020, match: ['oneplus buds']),
  CatalogDevice(id: 'oneplus_buds_pro', name: 'OnePlus Buds Pro', brand: 'OnePlus', emoji: '🎧', type: 'TWS', year: 2021, match: ['oneplus buds pro']),
  CatalogDevice(id: 'oneplus_buds_pro2', name: 'OnePlus Buds Pro 2', brand: 'OnePlus', emoji: '🎧', type: 'TWS', year: 2023, match: ['oneplus buds pro 2']),
  CatalogDevice(id: 'oneplus_buds3', name: 'OnePlus Buds 3', brand: 'OnePlus', emoji: '🎧', type: 'TWS', year: 2024, match: ['oneplus buds 3']),
  CatalogDevice(id: 'oneplus_buds4', name: 'OnePlus Buds 4', brand: 'OnePlus', emoji: '🎧', type: 'TWS', year: 2026, match: ['oneplus buds 4']),
  CatalogDevice(id: 'oneplus_nord_buds4', name: 'OnePlus Nord Buds 4', brand: 'OnePlus', emoji: '🎧', type: 'TWS', year: 2026, match: ['nord buds 4', 'oneplus nord buds 4']),
  CatalogDevice(id: 'nothing_ear1', name: 'Nothing Ear (1)', brand: 'Nothing', emoji: '🎧', type: 'TWS', year: 2021, match: ['nothing ear 1', 'ear (1)']),
  CatalogDevice(id: 'nothing_ear2', name: 'Nothing Ear (2)', brand: 'Nothing', emoji: '🎧', type: 'TWS', year: 2023, match: ['nothing ear 2', 'ear (2)']),
  CatalogDevice(id: 'nothing_ear3', name: 'Nothing Ear', brand: 'Nothing', emoji: '🎧', type: 'TWS', year: 2024, match: ['nothing ear']),
  CatalogDevice(id: 'nothing_ear_2026', name: 'Nothing Ear (3)', brand: 'Nothing', emoji: '🎧', type: 'TWS', year: 2026, match: ['nothing ear 3', 'ear (3)']),
  CatalogDevice(id: 'huawei_freebuds3', name: 'HUAWEI FreeBuds 3', brand: 'HUAWEI', emoji: '🎧', type: 'TWS', year: 2019, match: ['freebuds 3']),
  CatalogDevice(id: 'huawei_freebuds_pro', name: 'HUAWEI FreeBuds Pro', brand: 'HUAWEI', emoji: '🎧', type: 'TWS', year: 2020, match: ['freebuds pro']),
  CatalogDevice(id: 'huawei_freebuds_pro2', name: 'HUAWEI FreeBuds Pro 2', brand: 'HUAWEI', emoji: '🎧', type: 'TWS', year: 2022, match: ['freebuds pro 2']),
  CatalogDevice(id: 'huawei_freebuds_pro3', name: 'HUAWEI FreeBuds Pro 3', brand: 'HUAWEI', emoji: '🎧', type: 'TWS', year: 2023, match: ['freebuds pro 3']),
  CatalogDevice(id: 'soundcore_liberty4', name: 'Soundcore Liberty 4', brand: 'Soundcore', emoji: '🎧', type: 'TWS', year: 2022, match: ['liberty 4']),
  CatalogDevice(id: 'soundcore_liberty5', name: 'Soundcore Liberty 5', brand: 'Soundcore', emoji: '🎧', type: 'TWS', year: 2026, match: ['liberty 5']),
  CatalogDevice(id: 'soundcore_spaceone', name: 'Soundcore Space One', brand: 'Soundcore', emoji: '🎧', type: 'Over-ear', year: 2023, match: ['space one']),
  CatalogDevice(id: 'jabra_elite85h', name: 'Jabra Elite 85h', brand: 'Jabra', emoji: '🎧', type: 'Over-ear', year: 2019, match: ['elite 85h']),
  CatalogDevice(id: 'jabra_elite75t', name: 'Jabra Elite 75t', brand: 'Jabra', emoji: '🎧', type: 'TWS', year: 2019, match: ['elite 75t']),
  CatalogDevice(id: 'jabra_elite10', name: 'Jabra Elite 10', brand: 'Jabra', emoji: '🎧', type: 'TWS', year: 2023, match: ['elite 10']),
  CatalogDevice(id: 'marshall_monitor2', name: 'Marshall Monitor II ANC', brand: 'Marshall', emoji: '🎧', type: 'Over-ear', year: 2020, match: ['monitor ii', 'monitor 2']),
  CatalogDevice(id: 'marshall_major4', name: 'Marshall Major IV', brand: 'Marshall', emoji: '🎧', type: 'On-ear', year: 2020, match: ['major iv', 'major 4']),
  CatalogDevice(id: 'technics_az60', name: 'Technics EAH-AZ60', brand: 'Technics', emoji: '🎧', type: 'TWS', year: 2021, match: ['eah-az60', 'az60']),
  CatalogDevice(id: 'technics_az80', name: 'Technics EAH-AZ80', brand: 'Technics', emoji: '🎧', type: 'TWS', year: 2023, match: ['eah-az80', 'az80']),
  CatalogDevice(id: 'bowers_px7', name: 'Bowers & Wilkins PX7', brand: 'Bowers & Wilkins', emoji: '🎧', type: 'Over-ear', year: 2020, match: ['px7']),
  CatalogDevice(id: 'bowers_px8', name: 'Bowers & Wilkins Px8', brand: 'Bowers & Wilkins', emoji: '🎧', type: 'Over-ear', year: 2022, match: ['px8']),
  CatalogDevice(id: 'one_more_sonoflow', name: '1MORE SonoFlow Pro', brand: '1MORE', emoji: '🎧', type: 'Over-ear', year: 2023, match: ['1more sonoflow', 'sonoflow']),
  CatalogDevice(id: 'skullcandy_crusher3', name: 'Skullcandy Crusher 3', brand: 'Skullcandy', emoji: '🎧', type: 'Over-ear', year: 2025, match: ['crusher 3']),
  CatalogDevice(id: 'audio_technica_m50xbt2', name: 'Audio-Technica ATH-M50xBT2', brand: 'Audio-Technica', emoji: '🎧', type: 'Over-ear', year: 2021, match: ['m50xbt2', 'ath-m50xbt2']),
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
  RangeValues _years = const RangeValues(2015, 2026);

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

  Future<void> _saveSettings() async {
    final patterns = <String>{};
    for (final device in catalog) {
      if (_enabled.contains(device.id)) patterns.addAll(device.match.map((e) => e.toLowerCase()));
    }
    await _native.invokeMethod('saveDeviceSettings', {
      'downloaded': _downloaded.toList(),
      'enabled': _enabled.toList(),
      'enabledPatterns': patterns.toList(),
    });
  }

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
    _snack('${device.name} добавлено в скачанные');
  }

  Future<void> _downloadVisible() async {
    final list = _visibleCatalog;
    if (list.isEmpty) return;
    setState(() => _downloaded.addAll(list.map((e) => e.id)));
    await _saveSettings();
    _snack('Добавлено моделей: ${list.length}');
  }

  Future<void> _toggleEnabled(CatalogDevice device, bool value) async {
    if (!_downloaded.contains(device.id)) { _snack('Сначала скачайте модель'); return; }
    setState(() { value ? _enabled.add(device.id) : _enabled.remove(device.id); });
    await _saveSettings();
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  CatalogDevice? _matchDevice(String name) {
    final n = name.toLowerCase();
    for (final device in catalog) {
      if (device.match.any((m) => n.contains(m))) return device;
    }
    return null;
  }

  List<CatalogDevice> get _visibleCatalog {
    final q = _query.trim().toLowerCase();
    Iterable<CatalogDevice> source = catalog.where((d) => d.year >= _years.start.round() && d.year <= _years.end.round());
    if (_tab == 'downloaded') source = source.where((d) => _downloaded.contains(d.id));
    if (_tab == 'search') source = source.where((d) => _enabled.contains(d.id));
    if (q.isNotEmpty) source = source.where((d) => '${d.name} ${d.brand} ${d.year}'.toLowerCase().contains(q));
    return source.toList();
  }

  @override
  Widget build(BuildContext context) {
    final detected = _lastDevice;
    final detectedModel = detected == null ? null : _matchDevice(detected.name);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Connect', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: _overlayPermission, tooltip: 'Popup', icon: Icon(_overlay ? Icons.layers : Icons.layers_clear))],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _statusCard(),
          const SizedBox(height: 14),
          if (detected != null) _deviceCard(detected, detectedModel),
          const SizedBox(height: 14),
          _tabs(),
          const SizedBox(height: 12),
          _yearFilter(),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text('Найдено: ${_visibleCatalog.length}', style: const TextStyle(fontWeight: FontWeight.w800))),
            if (_tab == 'catalog') FilledButton.icon(onPressed: _downloadVisible, icon: const Icon(Icons.download_done), label: const Text('Скачать выбранные')),
          ]),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: _tab == 'search' ? 'Какие наушники искать?' : 'Поиск наушников, бренда или года',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          if (_tab == 'search') _searchInfo(),
          ..._visibleCatalog.map(_modelCard),
          if (_visibleCatalog.isEmpty) _emptyState(),
        ],
      ),
    );
  }

  Widget _statusCard() => Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Обнаружение наушников рядом', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(_running ? 'Сканирование активно' : 'Сканирование выключено'),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: _toggle, icon: Icon(_running ? Icons.stop : Icons.bluetooth_searching), label: Text(_running ? 'Остановить' : 'Включить'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: _overlayPermission, icon: Icon(_overlay ? Icons.check_circle : Icons.open_in_new), label: Text(_overlay ? 'Popup включён' : 'Включить popup'))),
            ]),
          ]),
        ),
      );

  Widget _tabs() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _tabButton('catalog', 'Все наушники', Icons.headphones),
          _tabButton('downloaded', 'Скачанные', Icons.download_done_rounded),
          _tabButton('search', 'Искать', Icons.radar_rounded),
        ]),
      );

  Widget _tabButton(String value, String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          selected: _tab == value,
          label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(title)]),
          onSelected: (_) => setState(() { _tab = value; _query = ''; }),
        ),
      );

  Widget _yearFilter() => Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Год выпуска: ${_years.start.round()} — ${_years.end.round()}', style: const TextStyle(fontWeight: FontWeight.w800)),
            RangeSlider(
              min: 2015,
              max: 2026,
              divisions: 11,
              values: _years,
              labels: RangeLabels('${_years.start.round()}', '${_years.end.round()}'),
              onChanged: (v) => setState(() => _years = v),
            ),
            Wrap(spacing: 6, children: [
              ActionChip(label: const Text('2015–2019'), onPressed: () => setState(() => _years = const RangeValues(2015, 2019))),
              ActionChip(label: const Text('2020–2023'), onPressed: () => setState(() => _years = const RangeValues(2020, 2023))),
              ActionChip(label: const Text('2024–2026'), onPressed: () => setState(() => _years = const RangeValues(2024, 2026))),
              ActionChip(label: const Text('Все'), onPressed: () => setState(() => _years = const RangeValues(2015, 2026))),
            ]),
          ]),
        ),
      );

  Widget _searchInfo() => const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Row(children: [Icon(Icons.info_outline), SizedBox(width: 10), Expanded(child: Text('В режиме «Искать» popup будет показываться только для скачанных и включённых наушников.'))]),
        ),
      );

  Widget _modelCard(CatalogDevice device) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: .05), borderRadius: BorderRadius.circular(16)),
              child: Text(device.emoji, style: const TextStyle(fontSize: 31)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(device.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('${device.brand} • ${device.type} • ${device.year}', style: TextStyle(color: Colors.grey.shade700)),
            ])),
            if (!_downloaded.contains(device.id))
              FilledButton.icon(onPressed: () => _download(device), icon: const Icon(Icons.download, size: 18), label: const Text('Скачать'))
            else
              Column(children: [
                const Text('Скачано', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Switch(value: _enabled.contains(device.id), onChanged: (v) => _toggleEnabled(device, v)),
              ]),
          ]),
        ),
      );

  Widget _deviceCard(DeviceInfo d, CatalogDevice? model) => Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            const DeviceArtwork(emoji: '🎧', size: 120),
            Text(model?.name ?? d.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('${d.rssi} dBm • ${model == null ? 'не из каталога' : (_enabled.contains(model.id) ? 'поиск включён' : 'поиск выключен')}'),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _connect, child: const Text('Подключить'))),
          ]),
        ),
      );

  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 38),
        child: Column(children: [
          const Icon(Icons.headphones_off_outlined, size: 52),
          const SizedBox(height: 10),
          Text(_tab == 'downloaded' ? 'Пока ничего не скачано' : _tab == 'search' ? 'Нет включённых наушников' : 'Наушники не найдены', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ]),
      );
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
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..setEntry(3, 2, .0012)..rotateY((_c.value * 6.283) - 3.1415),
          child: child,
        ),
        child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
      );
}
