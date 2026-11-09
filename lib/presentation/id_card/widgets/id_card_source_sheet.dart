import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';

enum IdCardSource { camera, gallery }

/// Dialog สไตล์ v2 ให้เลือกว่าจะ "ถ่ายรูป" หรือ "เลือกจากแกลเลอรี"
Future<IdCardSource?> showIdCardSourceSheet(BuildContext context) {
  final theme = Theme.of(context);
  return showDialog<IdCardSource>(
    context: context,
    barrierColor: const Color(0x8A0F172A),
    builder: (ctx) => Theme(data: theme, child: const _IdCardSourceDialog()),
  );
}

class _IdCardSourceDialog extends StatelessWidget {
  const _IdCardSourceDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: RegV2Colors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RegV2Radius.card + 4),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: RegV2Colors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    size: 34,
                    color: RegV2Colors.primary,
                  ),
                ),
              ),
              Column(
                spacing: 6,
                children: [
                  Text(
                    'เพิ่มรูปบัตรประชาชน',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 20,
                      color: RegV2Colors.text,
                    ),
                  ),
                  Text(
                    'เลือกวิธีที่สะดวก รูปควรชัด ไม่มีแสงสะท้อน',
                    textAlign: TextAlign.center,
                    style: RegV2Text.muted.copyWith(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
              const _SourceTile(
                source: IdCardSource.camera,
                icon: Icons.photo_camera_outlined,
                title: 'ถ่ายรูปด้วยกล้อง',
                subtitle: 'มีกรอบช่วยจัดตำแหน่งบัตร ใช้กล้องหลัง',
                recommended: true,
              ),
              const _SourceTile(
                source: IdCardSource.gallery,
                icon: Icons.photo_library_outlined,
                title: 'เลือกจากแกลเลอรี',
                subtitle: 'ไฟล์ JPG / PNG / WEBP ไม่เกิน 10 MB',
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'ยกเลิก',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 15.5,
                    color: RegV2Colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatefulWidget {
  const _SourceTile({
    required this.source,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.recommended = false,
  });

  final IdCardSource source;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool recommended;

  @override
  State<_SourceTile> createState() => _SourceTileState();
}

class _SourceTileState extends State<_SourceTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final highlight = _hover || widget.recommended;
    return InkWell(
      onTap: () => Navigator.of(context).pop(widget.source),
      onHover: (v) => setState(() => _hover = v),
      borderRadius: BorderRadius.circular(RegV2Radius.tile),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hover ? RegV2Colors.primarySoft : RegV2Colors.card,
          borderRadius: BorderRadius.circular(RegV2Radius.tile),
          border: Border.all(
            color: highlight ? RegV2Colors.primaryBorder : RegV2Colors.border,
            width: highlight ? 1.5 : 1,
          ),
          boxShadow: widget.recommended ? RegV2Shadows.selected : null,
        ),
        child: Row(
          spacing: 14,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RegV2Colors.primarySoft,
                borderRadius: BorderRadius.circular(RegV2Radius.input),
              ),
              child: Icon(widget.icon, color: RegV2Colors.primary, size: 26),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 16,
                            color: RegV2Colors.text,
                          ),
                        ),
                      ),
                      if (widget.recommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: RegV2Colors.positiveSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'แนะนำ',
                            style: AppTextStyles.medium.copyWith(
                              fontSize: 12,
                              color: RegV2Colors.positive,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(widget.subtitle, style: RegV2Text.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: RegV2Colors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
