import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/location_data.dart';
import '../models/place.dart';
import '../repositories/place_repository.dart';
import '../services/location_service.dart';
import '../services/map_service.dart';
import '../services/phone_service.dart';
import '../services/place_search_exception.dart';
import '../widgets/place_list_item.dart';
import '../widgets/search_bar.dart';
import 'place_detail_screen.dart';

/// Requests location, then lists nearby (or searched) stores by distance.
class HomeScreen extends StatefulWidget {
  final LocationService locationService;
  final PlaceRepository repository;
  final PhoneService phoneService;
  final MapService mapService;
  const HomeScreen({
    super.key,
    required this.locationService,
    required this.repository,
    required this.phoneService,
    required this.mapService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  LocationResult? _result;
  bool _locating = true;
  bool _loading = false;
  List<Place> _places = [];
  String? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _locating = true);
    final r = await widget.locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _result = r;
      _locating = false;
    });
    if (r.status == LocationStatus.ok) await _search(_searchController.text);
  }

  /// Empty keyword => nearby stores; otherwise keyword search. Always by distance.
  Future<void> _search(String keyword) async {
    final LocationData origin = _result!.location!;
    final id = ++_requestId; // ignore stale responses
    setState(() {
      _loading = true;
      _error = null;
    });
    List<Place> places = [];
    String? error;
    try {
      places = await widget.repository.search(keyword, origin);
    } catch (e) {
      error = e is PlaceSearchException
          ? e.message
          : '매장 정보를 불러오지 못했습니다. 네트워크 상태를 확인해 주세요.';
    }
    if (!mounted || id != _requestId) return;
    setState(() {
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

  Widget _centered(List<Widget> children) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children),
        ),
      );

  Widget _results() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _centered([
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(
            onPressed: () => _search(_searchController.text),
            child: const Text('다시 시도')),
      ]);
    }
    if (_places.isEmpty) {
      return const Center(child: Text(AppConstants.noResults));
    }
    return ListView.separated(
      itemCount: _places.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => PlaceListItem(
        place: _places[i],
        phoneService: widget.phoneService,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PlaceDetailScreen(
              place: _places[i],
              phoneService: widget.phoneService,
              mapService: widget.mapService),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    Widget body;
    if (_locating || r == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (r.status == LocationStatus.ok) {
      body = Column(children: [
        StoreSearchBar(controller: _searchController, onSubmitted: _search),
        Expanded(child: _results()),
      ]);
    } else {
      body = _centered([
        Text(_message(r.status), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: _init, child: const Text('다시 시도')),
        if (r.status == LocationStatus.deniedForever ||
            r.status == LocationStatus.serviceDisabled)
          TextButton(
              onPressed: widget.locationService.openSettings,
              child: const Text('설정으로 이동')),
      ]);
    }
    return Scaffold(appBar: AppBar(title: const Text('SearchYa')), body: body);
  }
}
