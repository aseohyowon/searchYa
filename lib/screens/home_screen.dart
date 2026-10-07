import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../services/location_service.dart';

/// STEP 2: shows permission/location state. Store list comes in STEP 3.
class HomeScreen extends StatefulWidget {
  final LocationService locationService;
  const HomeScreen({super.key, required this.locationService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationResult? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await widget.locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _result = r;
      _loading = false;
    });
  }

  String _message(LocationStatus s) {
    switch (s) {
      case LocationStatus.serviceDisabled:
        return '기기의 위치 서비스(GPS)가 꺼져 있습니다. 켜 주세요.';
      case LocationStatus.unavailable:
        return '현재 위치를 가져오지 못했습니다. 잠시 후 다시 시도해 주세요.';
      default:
        return AppConstants.locationDenied;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    Widget body;
    if (_loading || r == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (r.status == LocationStatus.ok) {
      body = Center(
          child: Text('현재 위치: ${r.location!.latitude}, ${r.location!.longitude}'));
    } else {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_message(r.status), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('다시 시도')),
            if (r.status == LocationStatus.deniedForever ||
                r.status == LocationStatus.serviceDisabled)
              TextButton(
                  onPressed: widget.locationService.openSettings,
                  child: const Text('설정으로 이동')),
          ]),
        ),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text('SearchYa')), body: body);
  }
}
