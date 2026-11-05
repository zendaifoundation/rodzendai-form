import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/pick_location_dialog_v2.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/radio_card_group.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_text_field.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

/// Step 5 — สถานที่รับผู้ป่วย: ชื่อ/ที่อยู่จุดรับ + ปักหมุด + จุดสังเกต
class StepPickupLocationView extends StatelessWidget {
  const StepPickupLocationView({super.key});

  Future<void> _openPicker(
    BuildContext context,
    RegisterToClaimYourRightsV2Provider provider,
  ) async {
    final lat = provider.pickupLatitude;
    final lng = provider.pickupLongitude;
    final centerAddress = await provider.currentAddressFullText();
    if (!context.mounted) return;

    final picked = await PickLocationDialogV2.show(
      context,
      initial: lat == null || lng == null
          ? null
          : PickedLocation(
              position: LatLng(lat, lng),
              formattedAddress: provider.pickupFormattedAddress,
              plusCode: provider.pickupPlusCode,
            ),
      centerAddress: centerAddress,
    );
    if (picked == null) return;
    provider.setPickupLocation(
      latitude: picked.position.latitude,
      longitude: picked.position.longitude,
      formattedAddress: picked.formattedAddress,
      plusCode: picked.plusCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();
    final lat = provider.pickupLatitude;
    final lng = provider.pickupLongitude;
    final position = lat == null || lng == null ? null : LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const RegV2SectionHeader(
          icon: Icons.place_outlined,
          title: 'จุดรับผู้ป่วย',
          subtitle: 'ตำแหน่งที่ให้รถไปรับผู้ป่วย',
        ),
        RegV2TextField(
          label: 'ชื่อสถานที่ / ที่อยู่จุดรับ',
          controller: provider.pickupDescriptionController,
          hintText: 'เช่น บ้านเลขที่ 12 ซอยสุขใจ หรือ ชื่อหมู่บ้าน/อาคาร',
          minLines: 2,
          maxLines: 4,
          validator: (value) => (value ?? '').trim().isEmpty
              ? 'กรุณากรอกชื่อสถานที่จุดรับ'
              : null,
        ),
        FormField<LatLng>(
          validator: (_) =>
              provider.hasPickupPin ? null : 'กรุณาปักหมุดจุดรับบนแผนที่',
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              const RegV2FieldLabel(text: 'ปักหมุดจุดรับ', fontSize: 16),
              if (position == null)
                _EmptyPin(
                  hasError: field.hasError,
                  onPick: () async {
                    await _openPicker(context, provider);
                    if (field.hasError) field.validate();
                  },
                )
              else
                _PinnedLocation(
                  position: position,
                  formattedAddress: provider.pickupFormattedAddress,
                  plusCode: provider.pickupPlusCode,
                  onEdit: () => _openPicker(context, provider),
                ),
              if (field.hasError) RegV2ErrorText(field.errorText!),
            ],
          ),
        ),
        RegV2TextField(
          label: 'จุดสังเกต / ทางเข้า (ถ้ามี)',
          isRequired: false,
          controller: provider.pickupLandmarkController,
          hintText: 'เช่น ตรงข้ามร้านสะดวกซื้อ ประตูสีเขียว',
        ),
      ],
    );
  }
}

class _EmptyPin extends StatelessWidget {
  const _EmptyPin({required this.hasError, required this.onPick});

  final bool hasError;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: RegV2Colors.background,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(
          color: hasError ? RegV2Colors.negative : RegV2Colors.border,
        ),
      ),
      child: Column(
        spacing: 12,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: RegV2Colors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_location_alt_outlined,
              color: RegV2Colors.primary,
              size: 28,
            ),
          ),
          Text(
            'ยังไม่ได้ปักหมุดจุดรับ',
            style: RegV2Text.sectionTitle.copyWith(fontSize: 16),
          ),
          Text(
            'ค้นหาสถานที่ แตะบนแผนที่ หรือใช้ตำแหน่งปัจจุบัน',
            textAlign: TextAlign.center,
            style: RegV2Text.muted.copyWith(fontSize: 14),
          ),
          FilledButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.map_outlined, size: 20),
            label: const Text('ปักหมุดบนแผนที่'),
          ),
        ],
      ),
    );
  }
}

class _PinnedLocation extends StatelessWidget {
  const _PinnedLocation({
    required this.position,
    required this.formattedAddress,
    required this.plusCode,
    required this.onEdit,
  });

  final LatLng position;
  final String? formattedAddress;
  final String? plusCode;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RegV2Colors.card,
        borderRadius: BorderRadius.circular(RegV2Radius.card),
        border: Border.all(color: RegV2Colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: GoogleMap(
              // key เปลี่ยนตามตำแหน่ง ให้ lite map วาดใหม่เมื่อย้ายหมุด
              key: ValueKey(position),
              initialCameraPosition: CameraPosition(target: position, zoom: 16),
              markers: {
                Marker(
                  markerId: const MarkerId('pickup_preview'),
                  position: position,
                ),
              },
              liteModeEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                PickedLocationSummary(
                  position: position,
                  formattedAddress: formattedAddress,
                  plusCode: plusCode,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_location_alt_outlined,
                      size: 20,
                    ),
                    label: const Text('แก้ไขตำแหน่ง'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
