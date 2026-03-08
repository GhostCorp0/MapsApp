import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SmoothRoute extends StatefulWidget {
  const SmoothRoute({super.key});

  @override
  State<SmoothRoute> createState() => _SmoothRouteState();
}

class _SmoothRouteState extends State<SmoothRoute>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  final List<LatLng> _routePoints = const [
    LatLng(28.6315, 77.2167),
    LatLng(28.6280, 77.2200),
    LatLng(28.6250, 77.2240),
    LatLng(28.6230, 77.2280),
    LatLng(28.6220, 77.2310),
    LatLng(28.6210, 77.2330),
    LatLng(28.6200, 77.2350),
    LatLng(28.6195, 77.2390),
    LatLng(28.6190, 77.2420),
    LatLng(28.6175, 77.2440),
    LatLng(28.6140, 77.2440),
    LatLng(28.6110, 77.2430),
    LatLng(28.6090, 77.2410),
    LatLng(28.6060, 77.2400),
    LatLng(28.6030, 77.2395),
  ];

  late LatLng _currentPosition;
  double _currentBearing = 0.0;
  BitmapDescriptor? _riderIcon;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};


  static const int _stepsPerSegment = 60;
  static const Duration _stepDuration = Duration(milliseconds: 16);

  int _segmentIndex = 0;
  int _stepIndex = 0;
  Timer? _animationTimer;
  bool _isPlaying = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = _routePoints.first;
    _loadRiderIcon();
    _buildPolyline();
    _buildMarkers();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadRiderIcon() async {
    try {
      final ByteData data =
      await rootBundle.load('assets/images/ic_live_location.png');
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 80,
        targetHeight: 80,
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData =
      await fi.image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && mounted) {
        setState(() {
          _riderIcon =
              BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
        });
        _buildMarkers();
      }
    } catch (e) {
      debugPrint('Icon load failed, using default: $e');
    }
  }

  void _buildPolyline() {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('remaining'),
        points: _routePoints,
        color: Colors.grey.shade400,
        width: 5,
        patterns: [PatternItem.dash(12), PatternItem.gap(6)],
      ),
    };
  }

  void _buildMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: _routePoints.first,
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pick-up'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: _routePoints.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Drop-off'),
      ),
      Marker(
        markerId: const MarkerId('rider'),
        position: _currentPosition,
        icon: _riderIcon ?? BitmapDescriptor.defaultMarker,
        rotation: _currentBearing,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 2,
      ),
    };
  }

  LatLng _lerpLatLng(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  double _bearing(LatLng a, LatLng b) {
    final double lat1 = a.latitude * pi / 180;
    final double lat2 = b.latitude * pi / 180;
    final double dLng = (b.longitude - a.longitude) * pi / 180;
    final double y = sin(dLng) * cos(lat2);
    final double x =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  void _startAnimation() {
    if (_isFinished) _resetAnimation();
    _isPlaying = true;
    _animationTimer =
        Timer.periodic(_stepDuration, (_) => _onAnimationTick());
    setState(() {});
  }

  void _pauseAnimation() {
    _isPlaying = false;
    _animationTimer?.cancel();
    _animationTimer = null;
    setState(() {});
  }

  void _resetAnimation() {
    _pauseAnimation();
    _segmentIndex = 0;
    _stepIndex = 0;
    _isFinished = false;
    _currentPosition = _routePoints.first;
    _currentBearing = 0;
    _buildMarkers();
    _animateCamera(_currentPosition);
    setState(() {});
  }

  void _onAnimationTick() {
    if (_segmentIndex >= _routePoints.length - 1) {
      _pauseAnimation();
      _isFinished = true;
      setState(() {});
      return;
    }

    final LatLng from = _routePoints[_segmentIndex];
    final LatLng to = _routePoints[_segmentIndex + 1];
    final double t = _stepIndex / _stepsPerSegment;

    _currentPosition = _lerpLatLng(from, to, t);
    _currentBearing = _bearing(from, to);

    _stepIndex++;
    if (_stepIndex > _stepsPerSegment) {
      _stepIndex = 0;
      _segmentIndex++;
    }

    _animateCamera(_currentPosition);

    setState(() {
      _buildMarkers();
      _updatePolylines();
    });
  }

  void _animateCamera(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 15.5,
          bearing: _currentBearing,
          tilt: 40,
        ),
      ),
    );
  }

  void _updatePolylines() {
    final List<LatLng> travelled =
    _routePoints.sublist(0, _segmentIndex + 1);
    travelled.add(_currentPosition);

    final List<LatLng> remaining = [_currentPosition];
    if (_segmentIndex + 1 < _routePoints.length) {
      remaining.addAll(_routePoints.sublist(_segmentIndex + 1));
    }

    _polylines = {
      Polyline(
        polylineId: const PolylineId('travelled'),
        points: travelled,
        color: const Color(0xFFFF6B00),
        width: 6,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
      if (remaining.length >= 2)
        Polyline(
          polylineId: const PolylineId('remaining'),
          points: remaining,
          color: Colors.grey.shade400,
          width: 5,
          patterns: [PatternItem.dash(12), PatternItem.gap(6)],
          jointType: JointType.round,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _routePoints.first,
              zoom: 15.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              Future.delayed(const Duration(milliseconds: 400), () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    _boundsFromPoints(_routePoints),
                    80,
                  ),
                );
              });
            },
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: _StatusCard(
              isPlaying: _isPlaying,
              isFinished: _isFinished,
              segmentIndex: _segmentIndex,
              totalSegments: _routePoints.length - 1,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _ControlBar(
                isPlaying: _isPlaying,
                isFinished: _isFinished,
                onPlay: _startAnimation,
                onPause: _pauseAnimation,
                onReset: _resetAnimation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isPlaying,
    required this.isFinished,
    required this.segmentIndex,
    required this.totalSegments,
  });

  final bool isPlaying;
  final bool isFinished;
  final int segmentIndex;
  final int totalSegments;

  @override
  Widget build(BuildContext context) {
    final double progress = totalSegments == 0
        ? 0
        : (segmentIndex / totalSegments).clamp(0.0, 1.0);
    final int percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFinished
                      ? Colors.green
                      : isPlaying
                      ? const Color(0xFFFF6B00)
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isFinished
                    ? 'Delivered! 🎉'
                    : isPlaying
                    ? 'Rider is on the way…'
                    : segmentIndex == 0
                    ? 'Tap Play to start'
                    : 'Paused',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B00),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF6B00)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('📍 Connaught Place',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('🏠 Lodi Garden',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.isPlaying,
    required this.isFinished,
    required this.onPlay,
    required this.onPause,
    required this.onReset,
  });

  final bool isPlaying;
  final bool isFinished;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onReset,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: const Icon(Icons.replay_rounded,
                  color: Colors.black87, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: isPlaying ? onPause : onPlay,
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF6B00),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55FF6B00),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isFinished
                    ? Icons.check_rounded
                    : isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: const [
                Icon(Icons.speed_rounded, size: 16, color: Colors.black54),
                SizedBox(width: 4),
                Text('Live',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}