import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/blocs/province_bloc/province_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_address_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_category_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_confirm_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_documents_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_patient_info_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_pickup_location_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/v2/step_transport_view.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/reg_v2_dialogs.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';

/// จอที่กว้างตั้งแต่ค่านี้แสดงขั้นตอนเป็น sidebar
const double _kSidebarBreakpoint = 960;

class RegisterToClaimYourRightsV2Page extends StatelessWidget {
  const RegisterToClaimYourRightsV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: registerV2Theme(Theme.of(context)),
      child: BlocProvider(
        // ใช้โดย ProvinceDropdown ใน Step 4
        create: (_) => ProvinceBloc()..add(const ProvinceRequested()),
        child: ChangeNotifierProvider(
          create: (_) => RegisterToClaimYourRightsV2Provider(),
          child: const _RegisterV2View(),
        ),
      ),
    );
  }
}

class _RegisterV2View extends StatefulWidget {
  const _RegisterV2View();

  @override
  State<_RegisterV2View> createState() => _RegisterV2ViewState();
}

class _RegisterV2ViewState extends State<_RegisterV2View> {
  final _scrollController = ScrollController();
  int? _lastIndex;

  /// จอแคบ: ย่อแถบขั้นตอนเมื่อเลื่อนลง ให้เนื้อหาแสดงได้มากขึ้น
  bool _compactTopBar = false;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastOffset;
    // กันกระพริบ: เปลี่ยนสถานะเมื่อเลื่อนเกินระยะเล็กน้อย
    if (delta.abs() < 8) return;
    _lastOffset = offset;
    // ที่ขอบล่าง ความสูงที่เปลี่ยนตอนย่อ/ขยายทำให้ offset ถูก clamp
    // ไม่นับเป็นการเลื่อนขึ้น เพื่อไม่ให้แถบย่อ-ขยายวนไปมา
    final position = _scrollController.position;
    if (delta < 0 && offset >= position.maxScrollExtent - 1) return;
    final compact = offset > 24 && delta > 0;
    if (compact != _compactTopBar) setState(() => _compactTopBar = compact);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    // เปลี่ยน step แล้วเลื่อนกลับไปบนสุด
    if (_lastIndex != null && _lastIndex != provider.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
        _lastOffset = 0;
        if (_compactTopBar && mounted) setState(() => _compactTopBar = false);
      });
    }
    _lastIndex = provider.currentIndex;

    final content = Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: _StepContent(step: provider.currentStep),
              ),
            ),
          ),
        ),
        const _BottomActions(),
      ],
    );

    return Scaffold(
      backgroundColor: RegV2Colors.background,
      appBar: AppBarCustomer(title: 'ลงทะเบียนรับสิทธิ์'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _kSidebarBreakpoint) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StepSidebar(),
                Expanded(child: content),
              ],
            );
          }
          return Column(
            children: [
              _StepTopBar(compact: _compactTopBar),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// แถบขั้นตอน
// -----------------------------------------------------------------------------

/// จอกว้าง: sidebar สีเขียวเข้ม รายการขั้นตอนแนวตั้ง
class _StepSidebar extends StatelessWidget {
  const _StepSidebar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();
    final steps = provider.steps;

    return Container(
      width: 280,
      color: RegV2Colors.sidebar,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  'สมัครใช้บริการรถรับ–ส่งผู้ป่วย',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ขั้นตอนที่ ${provider.currentIndex + 1} จาก ${steps.length}',
                  style: AppTextStyles.regular.copyWith(
                    fontSize: 14,
                    color: RegV2Colors.sidebarMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            value: (provider.currentIndex + 1) / steps.length,
            onDark: true,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: steps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, i) => _SidebarItem(
                index: i,
                step: steps[i],
                isActive: i == provider.currentIndex,
                isCompleted: provider.isStepCompleted(steps[i]),
                onTap: () => provider.goTo(steps[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.index,
    required this.step,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  final int index;
  final RegisterV2Step step;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? Colors.white.withAlpha(28) : Colors.transparent,
      borderRadius: BorderRadius.circular(RegV2Radius.tile),
      child: InkWell(
        borderRadius: BorderRadius.circular(RegV2Radius.tile),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              _StepBullet(
                index: index,
                step: step,
                isActive: isActive,
                isCompleted: isCompleted,
                onDark: true,
              ),
              Expanded(
                child: Text(
                  step.title,
                  style: (isActive ? AppTextStyles.bold : AppTextStyles.regular)
                      .copyWith(
                        fontSize: 15,
                        color: isActive || isCompleted
                            ? Colors.white
                            : Colors.white.withAlpha(170),
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

/// จอแคบ: วงแหวนความคืบหน้า + ชื่อขั้นตอน + ขั้นถัดไป และแถบ segment แตะเพื่อย้อนกลับได้
class _StepTopBar extends StatelessWidget {
  const _StepTopBar({this.compact = false});

  /// true = ย่อเหลือบรรทัดเดียว (ตอนเลื่อนเนื้อหาลง)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();
    final steps = provider.steps;
    final current = provider.currentIndex;
    final next = current + 1 < steps.length ? steps[current + 1] : null;

    return Container(
      decoration: const BoxDecoration(
        color: RegV2Colors.card,
        border: Border(bottom: BorderSide(color: RegV2Colors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, compact ? 8 : 14, 16, compact ? 4 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: compact ? 4 : 14,
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeOut,
            crossFadeState: compact
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            secondChild: Row(
              spacing: 10,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: RegV2Colors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${current + 1}/${steps.length}',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 12,
                      color: RegV2Colors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    provider.currentStep.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 15,
                      color: RegV2Colors.text,
                    ),
                  ),
                ),
              ],
            ),
            firstChild: Row(
              spacing: 14,
              children: [
                _ProgressRing(current: current + 1, total: steps.length),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'ขั้นตอนที่ ${current + 1} จาก ${steps.length}',
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 12,
                          letterSpacing: 0.2,
                          color: RegV2Colors.primary,
                        ),
                      ),
                      Text(
                        provider.currentStep.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 18,
                          color: RegV2Colors.text,
                        ),
                      ),
                      Text(
                        next == null
                            ? 'ขั้นตอนสุดท้าย'
                            : 'ถัดไป: ${next.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RegV2Text.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 4,
            children: [
              for (var i = 0; i < steps.length; i++)
                Expanded(
                  child: _StepSegment(
                    label: '${i + 1}. ${steps[i].title}',
                    isActive: i == current,
                    isDone: i < current || provider.isStepCompleted(steps[i]),
                    onTap: () => provider.goTo(steps[i]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// วงแหวนแสดงความคืบหน้า x/n
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: current / total),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                backgroundColor: RegV2Colors.primarySoft,
                valueColor: const AlwaysStoppedAnimation(RegV2Colors.primary),
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$current',
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 16,
                    color: RegV2Colors.primary,
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: AppTextStyles.medium.copyWith(
                    fontSize: 11,
                    color: RegV2Colors.textSubtle,
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

/// แถบย่อยของแต่ละขั้นตอน (พื้นที่แตะสูง 20px ตัวแถบ 6px)
class _StepSegment extends StatelessWidget {
  const _StepSegment({
    required this.label,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? RegV2Colors.primary
        : isDone
        ? RegV2Colors.primary.withAlpha(110)
        : RegV2Colors.divider;

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 20,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: isActive ? 6 : 5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBullet extends StatelessWidget {
  const _StepBullet({
    required this.index,
    required this.step,
    required this.isActive,
    required this.isCompleted,
    this.onDark = false,
  });

  final int index;
  final RegisterV2Step step;
  final bool isActive;
  final bool isCompleted;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    if (isActive) {
      bg = onDark ? Colors.white : RegV2Colors.primary;
      fg = onDark ? RegV2Colors.sidebar : Colors.white;
      border = bg;
    } else if (isCompleted) {
      bg = onDark ? RegV2Colors.sidebarMuted : RegV2Colors.primarySoft;
      fg = onDark ? RegV2Colors.sidebar : RegV2Colors.primary;
      border = onDark ? bg : RegV2Colors.primaryBorder;
    } else {
      bg = Colors.transparent;
      fg = onDark ? Colors.white.withAlpha(170) : RegV2Colors.textSubtle;
      border = onDark ? Colors.white.withAlpha(90) : RegV2Colors.border;
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: 1.5),
      ),
      child: isCompleted && !isActive
          ? Icon(Icons.check_rounded, size: 16, color: fg)
          : Text(
              '${index + 1}',
              style: AppTextStyles.bold.copyWith(fontSize: 13, color: fg),
            ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, this.onDark = false});

  final double value;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: onDark
            ? Colors.white.withAlpha(40)
            : RegV2Colors.divider,
        valueColor: AlwaysStoppedAnimation(
          onDark ? RegV2Colors.sidebarMuted : RegV2Colors.primary,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// เนื้อหาแต่ละ step
// -----------------------------------------------------------------------------

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step});

  final RegisterV2Step step;

  String get _eyebrow => 'ขั้นตอนที่ ${step.index + 1}';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RegisterToClaimYourRightsV2Provider>();
    final form = Form(
      key: provider.formKeyOf(step),
      child: switch (step) {
        RegisterV2Step.category => const StepCategoryView(),
        RegisterV2Step.transport => const StepTransportView(),
        RegisterV2Step.patientInfo => const StepPatientInfoView(),
        RegisterV2Step.address => const StepAddressView(),
        RegisterV2Step.pickupLocation => const StepPickupLocationView(),
        RegisterV2Step.documents => const StepDocumentsView(),
        RegisterV2Step.confirm => const StepConfirmView(),
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              _eyebrow.toUpperCase(),
              style: AppTextStyles.bold.copyWith(
                fontSize: 13,
                letterSpacing: 0.4,
                color: RegV2Colors.accent,
              ),
            ),
            Text(step.title, style: RegV2Text.pageTitle),
          ],
        ),
        RegV2Card(child: form),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ปุ่มด้านล่าง
// -----------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  /// เลื่อนไปยังช่องแรก (บนสุด) ที่ validate ไม่ผ่านใน form ของ step ปัจจุบัน
  void _scrollToFirstError(GlobalKey<FormState> formKey) {
    // รอให้ข้อความ error วาดเสร็จก่อน ตำแหน่งจะได้ถูกต้อง
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formContext = formKey.currentContext;
      if (formContext is! Element) return;

      Element? firstError;
      void visit(Element element) {
        if (firstError != null) return;
        if (element is StatefulElement &&
            element.state is FormFieldState &&
            (element.state as FormFieldState).hasError) {
          firstError = element;
          return;
        }
        element.visitChildren(visit);
      }

      formContext.visitChildren(visit);
      final target = firstError;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    });
  }

  Future<void> _onNext(
    BuildContext context,
    RegisterToClaimYourRightsV2Provider provider,
  ) async {
    if (!provider.isLastStep) {
      if (!provider.next()) {
        // step ที่อยู่: ช่องครบแต่ที่อยู่ปัจจุบันอยู่นอกพื้นที่ให้บริการ → แจ้งเป็น dialog
        if (provider.currentStep == RegisterV2Step.address &&
            !provider.isCurrentAddressInServiceArea &&
            (provider
                    .formKeyOf(provider.currentStep)
                    .currentState
                    ?.validate() ??
                true)) {
          await RegV2Dialogs.warning(
            context,
            title: 'ที่อยู่ไม่อยู่ในพื้นที่ให้บริการ',
            message:
                'ที่อยู่ปัจจุบันไม่อยู่ในพื้นที่ให้บริการของโครงการ\n'
                'กรุณากรอกที่อยู่ปัจจุบันที่พักอาศัยจริงในพื้นที่โครงการ',
          );
          return;
        }
        _scrollToFirstError(provider.formKeyOf(provider.currentStep));
      }
      return;
    }

    // step สุดท้าย: ตรวจข้อมูล step 7 แล้วถามยืนยันก่อนบันทึก
    if (!provider.validateStep(provider.currentStep)) {
      _scrollToFirstError(provider.formKeyOf(provider.currentStep));
      return;
    }
    final confirmed = await RegV2Dialogs.confirm(
      context,
      icon: Icons.send_rounded,
      title: 'ยืนยันส่งคำขอ',
      message:
          'ต้องการส่งคำขอให้เจ้าหน้าที่พิจารณาใช่หรือไม่?\n'
          'การส่งคำขอยังไม่ใช่การอนุมัติสิทธิ เจ้าหน้าที่จะตรวจสอบและแจ้งผลภายหลัง',
      confirmText: 'ส่งคำขอ',
      cancelText: 'กลับไปตรวจสอบ',
    );
    if (confirmed != true || !context.mounted) return;

    final success = await provider.submit();
    if (!context.mounted) return;

    if (success) {
      await RegV2Dialogs.success(
        context,
        title: 'ส่งคำขอเรียบร้อย',
        message: 'สถานะ: รอเจ้าหน้าที่ตรวจสอบ',
      );
      if (context.mounted) context.go('/home');
    } else {
      await RegV2Dialogs.error(
        context,
        title: 'ส่งคำขอไม่สำเร็จ',
        message: provider.errorMessage ?? 'กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();
    // Step 7: ต้องติ๊กยืนยันครบ 2 ข้อก่อนจึงกดถัดไปได้
    // ตัวหนังสือปุ่มเล็กกว่าค่าเริ่มต้นของธีม (16) เล็กน้อย
    final buttonText = AppTextStyles.medium.copyWith(fontSize: 15.5);
    final blockedByConfirmation =
        provider.currentStep == RegisterV2Step.confirm &&
        !provider.isConfirmationCompleted;

    return Container(
      decoration: const BoxDecoration(
        color: RegV2Colors.card,
        border: Border(top: BorderSide(color: RegV2Colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Row(
            spacing: 12,
            children: [
              if (!provider.isFirstStep)
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: provider.isSubmitting ? null : provider.back,
                    style: OutlinedButton.styleFrom(textStyle: buttonText),
                    child: const Text('ย้อนกลับ'),
                  ),
                ),
              Expanded(
                flex: 5,
                child: FilledButton(
                  onPressed: provider.isSubmitting || blockedByConfirmation
                      ? null
                      : () => _onNext(context, provider),
                  style: FilledButton.styleFrom(textStyle: buttonText),
                  child: provider.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          provider.isLastStep
                              ? 'ส่งคำขอให้เจ้าหน้าที่พิจารณา'
                              : 'ถัดไป',
                          overflow: TextOverflow.ellipsis,
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
