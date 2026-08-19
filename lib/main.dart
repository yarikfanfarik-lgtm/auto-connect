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
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF111111)),
    home: const HomePage(),
  );
}

class DeviceInfo {
  final String name;
  final String address;
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
  bool _running = false;
  bool _overlay = false;
  DeviceInfo? _lastDevice;
  final Set<String> _models = {'airpods', 'buds', 'watch', 'headphones', 'wh-1000xm', 'beats', 'galaxy watch'};

  @override
  void initState() {
    super.initState();
    _events = EventChannel('auto_connect/events').receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final name = (event['name'] ?? 'Bluetooth device').toString();
        final address = (event['address'] ?? '').toString();
        final rssi = int.tryParse('${event['rssi'] ?? -100}') ?? -100;
        if (mounted) setState(() => _lastDevice = DeviceInfo(name: name, address: address, rssi: rssi));
      }
    });
  }

  @override
  void dispose() { _events?.cancel(); super.dispose(); }

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

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  bool _hasModel(String name) => _models.any((m) => name.toLowerCase().contains(m));

  @override
  Widget build(BuildContext context) {
    final d = _lastDevice;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(title: const Text('Auto Connect', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _statusCard(),
          const SizedBox(height: 16),
          if (d != null) _deviceCard(d),
          const SizedBox(height: 20),
          const Text('Модели устройств', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Модель показывается в popup, если имя обнаруженного устройства совпадает с каталогом.'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _models.map((m) => Chip(label: Text(m))).toList()),
        ],
      ),
    );
  }

  Widget _statusCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Обнаружение рядом', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(_running ? 'Сканирование активно' : 'Сканирование выключено'),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _toggle, icon: Icon(_running ? Icons.stop : Icons.bluetooth_searching), label: Text(_running ? 'Остановить' : 'Включить обнаружение')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: _overlayPermission, icon: Icon(_overlay ? Icons.check_circle : Icons.open_in_new), label: Text(_overlay ? 'Popup поверх приложений: включён' : 'Разрешить popup поверх приложений')),
      ]),
    ),
  );

  Widget _deviceCard(DeviceInfo d) => Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        DeviceArtwork(name: d.name, size: 180),
        Text(d.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('${d.rssi} dBm • ${_hasModel(d.name) ? 'модель найдена' : 'модель не добавлена'}'),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: _connect, child: const Text('Подключить', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)))),
      ]),
    ),
  );
}

class DeviceArtwork extends StatefulWidget {
  final String name;
  final double size;
  const DeviceArtwork({super.key, required this.name, required this.size});
  @override State<DeviceArtwork> createState() => _DeviceArtworkState();
}

class _DeviceArtworkState extends State<DeviceArtwork> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) => Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..setEntry(3, 2, .0012)..rotateY((_c.value * 6.283) - 3.1415),
      child: child,
    ),
    child: Icon(widget.name.toLowerCase().contains('watch') ? Icons.watch : Icons.headphones, size: widget.size),
  );
}
