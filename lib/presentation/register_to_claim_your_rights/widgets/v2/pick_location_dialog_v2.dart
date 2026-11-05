import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/places_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/register/blocs/get_latlng_bloc/get_latlng_bloc.dart';
import 'package:rodzendai_form/presentation/register/blocs/places_autocomplete_bloc/places_autocomplete_bloc.dart';
import 'package:rodzendai_form/presentation/register/widgets/custom_place_autocomplete.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// ผลลัพธ์จากการปักหมุด
class PickedLocation {
  const PickedLocation({
    required this.position,
    this.formattedAddress,
    this.plusCode,
  });

  final LatLng position;
  final String? formattedAddress;
  final String? plusCode;
}

/// Dialog ปักหมุดสถานที่รับผู้ป่วย (v2)
///
/// เก็บ state ไว้ในตัวเอง คืน [PickedLocation] เมื่อกดยืนยัน หรือ null เมื่อยกเลิก
/// ค้นหาสถานที่ / พิมพ์พิกัด "lat, lng" / แตะแผนที่ / ลากหมุด / ใช้ตำแหน่งปัจจุบัน
class PickLocationDialogV2 extends StatefulWidget {
  const PickLocationDialogV2({super.key, this.initial, this.centerAddress});

  final PickedLocation? initial;

  /// ที่อยู่ที่ใช้จัดกึ่งกลางแผนที่ตอนเปิดครั้งแรก (ยังไม่ปักหมุดให้)
  final String? centerAddress;

  static Future<PickedLocation?> show(
    BuildContext context, {
    PickedLocation? initial,
    String? centerAddress,
  }) {
    return showDialog<PickedLocation>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Theme(
        data: registerV2Theme(Theme.of(context)),
        child: PickLocationDialogV2(
          initial: initial,
          centerAddress: centerAddress,
        ),
      ),
    );
  }

  @override
  State<PickLocationDialogV2> createState() => _PickLocationDialogV2State();
}

class _PickLocationDialogV2State extends State<PickLocationDialogV2> {
  static const _defaultCenter = LatLng(13.7563, 100.5018); // กรุงเทพฯ

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _getLatLngBloc = GetLatLngBloc();
  final _centerLatLngBloc = GetLatLngBloc();
  final _locationDetailBloc = GetLocationDetailBloc();
  final _placesBloc = PlacesAutocompleteBloc(
    placesService: locator<PlacesService>(),
  );

  GoogleMapController? _mapController;
  LatLng? _selected;
  String? _formattedAddress;
  String? _plusCode;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial?.position;
    _formattedAddress = widget.initial?.formattedAddress;
    _plusCode = widget.initial?.plusCode;
    _searchController.addListener(_onSearchTextChanged);

    final centerAddress = widget.centerAddress?.trim() ?? '';
    if (_selected == null && centerAddress.isNotEmpty) {
      _centerLatLngBloc.add(GetLatLngFromAddressEvent(address: centerAddress));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _getLatLngBloc.close();
    _centerLatLngBloc.close();
    _locationDetailBloc.close();
    _placesBloc.close();
    super.dispose();
  }

  /// พิมพ์พิกัด "13.79689, 100.56053" แล้วปักหมุดทันที
  void _onSearchTextChanged() {
    final parts = _searchController.text.split(',');
    if (parts.length != 2) return;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return;
    _searchFocusNode.unfocus();
    _placesBloc.add(const ClearPlacesEvent());
    _pin(LatLng(lat, lng));
  }

  void _pin(LatLng position, {String? formattedAddress}) {
    setState(() {
      _selected = position;
      _formattedAddress = formattedAddress;
      _plusCode = null;
    });
    _moveCamera(position);
    _locationDetailBloc.add(
      GetLocationDetailRequestEvent(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
  }

  void _moveCamera(LatLng target, {double zoom = 16}) {
    try {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
    } catch (e) {
      log('⚠️ animateCamera failed: $e');
      _mapController = null;
    }
  }

  Future<void> _useCurrentPosition() async {
    setState(() => _isLocating = true);
    try {
      if (!kIsWeb) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง');
        }
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));
      _pin(LatLng(position.latitude, position.longitude));
    } catch (e) {
      log('❌ getCurrentPosition failed: $e');
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'ไม่สามารถดึงตำแหน่งปัจจุบันได้ กรุณาตรวจสอบการอนุญาตตำแหน่ง',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final selected = _selected;

    return MultiBlocListener(
      listeners: [
        BlocListener<GetLatLngBloc, GetLatLngState>(
          bloc: _getLatLngBloc,
          listener: (context, state) {
            if (state is GetLatLngSuccess) {
              _pin(
                LatLng(state.latitude, state.longitude),
                formattedAddress: _formattedAddress,
              );
            }
          },
        ),
        BlocListener<GetLatLngBloc, GetLatLngState>(
          bloc: _centerLatLngBloc,
          listener: (context, state) {
            // จัดกึ่งกลางเท่านั้น ไม่ปักหมุดแทนผู้ใช้
            if (state is GetLatLngSuccess && _selected == null) {
              _moveCamera(LatLng(state.latitude, state.longitude), zoom: 15);
            }
          },
        ),
        BlocListener<GetLocationDetailBloc, GetLocationDetailState>(
          bloc: _locationDetailBloc,
          listener: (context, state) {
            if (state is GetLocationDetailSuccess) {
              setState(() {
                _formattedAddress = state.addressDetail.formattedAddress;
                _plusCode = state.addressDetail.plusCode;
              });
            }
          },
        ),
      ],
      child: BlocProvider.value(
        value: _placesBloc,
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: media.size.width > 720 ? 48 : 12,
            vertical: 24,
          ),
          backgroundColor: RegV2Colors.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RegV2Radius.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 760,
              maxHeight: media.size.height * 0.92,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogHeader(onClose: () => Navigator.of(context).pop()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: CustomPlaceAutocomplete(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSelected: (prediction) {
                      final description = prediction['description'];
                      if (description != null) {
                        _searchController.text = description;
                        setState(() => _formattedAddress = description);
                      }
                      final placeId = prediction['place_id'];
                      if (placeId != null) {
                        _getLatLngBloc.add(
                          GetLatLngFromPlaceIdEvent(placeId: placeId),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(RegV2Radius.tile),
                      child: Stack(
                        children: [
                          GoogleMap(
                            onMapCreated: (controller) =>
                                _mapController = controller,
                            initialCameraPosition: CameraPosition(
                              target: selected ?? _defaultCenter,
                              zoom: selected == null ? 12 : 16,
                            ),
                            markers: {
                              if (selected != null)
                                Marker(
                                  markerId: const MarkerId('pickup_location'),
                                  position: selected,
                                  draggable: true,
                                  onDragEnd: _pin,
                                ),
                            },
                            onTap: (position) {
                              _searchFocusNode.unfocus();
                              _placesBloc.add(const ClearPlacesEvent());
                              _pin(position);
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: false,
                          ),
                          Positioned(
                            left: 12,
                            top: 12,
                            child: _MapChipButton(
                              icon: Icons.my_location_rounded,
                              label: 'ใช้ตำแหน่งปัจจุบัน',
                              isLoading: _isLocating,
                              onPressed: _isLocating
                                  ? null
                                  : _useCurrentPosition,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child:
                      BlocBuilder<
                        GetLocationDetailBloc,
                        GetLocationDetailState
                      >(
                        bloc: _locationDetailBloc,
                        builder: (context, state) => PickedLocationSummary(
                          position: selected,
                          formattedAddress: _formattedAddress,
                          plusCode: _plusCode,
                          isLoading: state is GetLocationDetailLoading,
                          emptyText:
                              'แตะบนแผนที่ ค้นหาสถานที่ หรือพิมพ์พิกัด "lat, lng"',
                        ),
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: selected == null
                              ? null
                              : () => Navigator.of(context).pop(
                                  PickedLocation(
                                    position: selected,
                                    formattedAddress: _formattedAddress,
                                    plusCode: _plusCode,
                                  ),
                                ),
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: const Text('ยืนยันตำแหน่ง'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: RegV2Colors.border)),
      ),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: RegV2Colors.primarySoft,
              borderRadius: BorderRadius.circular(RegV2Radius.input),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: RegV2Colors.primary,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              'ปักหมุดสถานที่รับผู้ป่วย',
              style: RegV2Text.sectionTitle,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'ปิด',
          ),
        ],
      ),
    );
  }
}

class _MapChipButton extends StatelessWidget {
  const _MapChipButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 18, color: RegV2Colors.primary),
              Text(
                label,
                style: AppTextStyles.medium.copyWith(
                  fontSize: 14,
                  color: RegV2Colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// สรุปตำแหน่งที่ปักหมุด: ที่อยู่ + พิกัด (+ plus code)
class PickedLocationSummary extends StatelessWidget {
  const PickedLocationSummary({
    super.key,
    required this.position,
    this.formattedAddress,
    this.plusCode,
    this.isLoading = false,
    this.emptyText = 'ยังไม่ได้ปักหมุด',
  });

  final LatLng? position;
  final String? formattedAddress;
  final String? plusCode;
  final bool isLoading;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final position = this.position;
    final hasPin = position != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasPin ? RegV2Colors.positiveSoft : RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        border: Border.all(
          color: hasPin
              ? RegV2Colors.positive.withAlpha(90)
              : RegV2Colors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(
            hasPin ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 20,
            color: hasPin ? RegV2Colors.positive : RegV2Colors.textSubtle,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  !hasPin
                      ? emptyText
                      : isLoading
                      ? 'กำลังค้นหาที่อยู่...'
                      : (formattedAddress?.isNotEmpty == true
                            ? formattedAddress!
                            : 'ปักหมุดแล้ว'),
                  style: RegV2Text.body.copyWith(
                    color: hasPin ? RegV2Colors.text : RegV2Colors.textMuted,
                  ),
                ),
                if (hasPin)
                  Text(
                    [
                      '${position.latitude.toStringAsFixed(6)}, '
                          '${position.longitude.toStringAsFixed(6)}',
                      if (plusCode?.isNotEmpty == true) plusCode!,
                    ].join('  •  '),
                    style: RegV2Text.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
