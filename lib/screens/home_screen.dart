import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/place.dart';
import '../repositories/place_repository.dart';
import '../services/location_service.dart';
import '../widgets/place_list_item.dart';

/// Requests location, then lists nearby stores sorted by distance.
class HomeScreen extends StatefulWidget {
  final LocationService locationService;
  final PlaceRepository repository;
  const HomeScreen(
      {super.key, required this.locationService, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationResult? _result;
  bool _loading = true;
  List<Place> _places = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await widget.locationService.getCurrentLocation();
    var places = <Place>[];
    String? error;
    if (r.status == LocationStatus.ok) {
      try {
        places = await widget.repository.nearby(r.location!);
      } catch (_) {
        error = '매장 정보를 불러오지 못했습니다. 네트워크 상태를 확인해 주세요.';
      }
    }
    if (!mounted) return;
    setState(() {
      _result = r;
      _places = places;
      _error = error;
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
      if (_error != null) {
        body = Center(child: Text(_error!));
      } else if (_places.isEmpty) {
        body = const Center(child: Text(AppConstants.noResults));
      } else {
        body = ListView.separated(
          itemCount: _places.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => PlaceListItem(place: _places[i]),
        );
      }
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
