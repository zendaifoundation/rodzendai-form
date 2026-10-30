import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/register_v2_theme.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';

/// จอที่กว้างตั้งแต่ค่านี้แสดงขั้นตอนเป็น sidebar
const double _kSidebarBreakpoint = 960;

/// โครงหน้าฟอร์มแบบหลายขั้นตอนสไตล์ v2
///
/// - จอกว้าง: sidebar รายการขั้นตอนด้านซ้าย
/// - จอแคบ: แถบความคืบหน้าด้านบน ย่อเมื่อเลื่อนลง
/// - เนื้อหา [child] ถูกครอบด้วยหัวข้อ "ขั้นตอนที่ N" + [RegV2Card]
///   (ปิดการ์ดได้ด้วย [wrapInCard] เมื่อเนื้อหาเป็นการ์ดอยู่แล้ว)
/// - [bottomBar] ปุ่มด้านล่าง
///
/// ไม่ผูกกับ provider ใด ผู้เรียกส่ง index / สถานะของแต่ละ step เข้ามาเอง
class RegV2StepScaffold extends StatefulWidget {
  const RegV2StepScaffold({
    super.key,
    required this.appBarTitle,
    required this.sidebarTitle,
    required this.stepTitles,
    required this.currentIndex,
    required this.isStepCompleted,
    required this.onStepTap,
    required this.child,
    required this.bottomBar,
    this.wrapInCard = true,
  });

  final String appBarTitle;
  final String sidebarTitle;
  final List<String> stepTitles;
  final int currentIndex;
  final bool Function(int index) isStepCompleted;
  final ValueChanged<int> onStepTap;
  final Widget child;
  final Widget bottomBar;
  final bool wrapInCard;

  @override
  State<RegV2StepScaffold> createState() => _RegV2StepScaffoldState();
}

class _RegV2StepScaffoldState extends State<RegV2StepScaffold> {
  final _scrollController = ScrollController();

  /// จอแคบ: ย่อแถบขั้นตอนเมื่อเลื่อนลง ให้เนื้อหาแสดงได้มากขึ้น
  bool _compactTopBar = false;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant RegV2StepScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // เปลี่ยน step แล้วเลื่อนกลับไปบนสุด
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
        _lastOffset = 0;
        if (_compactTopBar) setState(() => _compactTopBar = false);
      });
    }
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
    final stepTitle = widget.stepTitles[widget.currentIndex];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'ขั้นตอนที่ ${widget.currentIndex + 1}'.toUpperCase(),
                          style: AppTextStyles.bold.copyWith(
                            fontSize: 13,
                            letterSpacing: 0.4,
                            color: RegV2Colors.accent,
                          ),
                        ),
                        Text(stepTitle, style: RegV2Text.pageTitle),
                      ],
                    ),
                    if (widget.wrapInCard)
                      RegV2Card(child: widget.child)
                    else
                      widget.child,
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.bottomBar,
      ],
    );

    return Scaffold(
      backgroundColor: RegV2Colors.background,
      appBar: AppBarCustomer(title: widget.appBarTitle),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _kSidebarBreakpoint) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepSidebar(
                  title: widget.sidebarTitle,
                  stepTitles: widget.stepTitles,
                  currentIndex: widget.currentIndex,
                  isStepCompleted: widget.isStepCompleted,
                  onStepTap: widget.onStepTap,
                ),
                Expanded(child: content),
              ],
            );
          }
          return Column(
            children: [
              _StepTopBar(
                compact: _compactTopBar,
                stepTitles: widget.stepTitles,
                currentIndex: widget.currentIndex,
                isStepCompleted: widget.isStepCompleted,
                onStepTap: widget.onStepTap,
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

/// ปุ่มย้อนกลับ / ถัดไป ด้านล่างของ [RegV2StepScaffold]
class RegV2StepBottomBar extends StatelessWidget {
  const RegV2StepBottomBar({
    super.key,
    required this.onNext,
    required this.nextLabel,
    this.onBack,
    this.isSubmitting = false,
  });

  /// null = ปุ่มถัดไปกดไม่ได้
  final VoidCallback? onNext;
  final String nextLabel;

  /// null = ซ่อนปุ่มย้อนกลับ (step แรก)
  final VoidCallback? onBack;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    // ตัวหนังสือปุ่มเล็กกว่าค่าเริ่มต้นของธีม (16) เล็กน้อย
    final buttonText = AppTextStyles.medium.copyWith(fontSize: 15.5);

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
              if (onBack != null)
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : onBack,
                    style: OutlinedButton.styleFrom(textStyle: buttonText),
                    child: const Text('ย้อนกลับ'),
                  ),
                ),
              Expanded(
                flex: 5,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onNext,
                  style: FilledButton.styleFrom(textStyle: buttonText),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(nextLabel, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// เลื่อนไปยังช่องแรก (บนสุด) ที่ validate ไม่ผ่านใน form
void regV2ScrollToFirstError(GlobalKey<FormState> formKey) {
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

// -----------------------------------------------------------------------------
// แถบขั้นตอน
// -----------------------------------------------------------------------------

/// จอกว้าง: sidebar สีเข้ม รายการขั้นตอนแนวตั้ง
class _StepSidebar extends StatelessWidget {
  const _StepSidebar({
    required this.title,
    required this.stepTitles,
    required this.currentIndex,
    required this.isStepCompleted,
    required this.onStepTap,
  });

  final String title;
  final List<String> stepTitles;
  final int currentIndex;
  final bool Function(int index) isStepCompleted;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
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
                  title,
                  style: AppTextStyles.bold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ขั้นตอนที่ ${currentIndex + 1} จาก ${stepTitles.length}',
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
            value: (currentIndex + 1) / stepTitles.length,
            onDark: true,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: stepTitles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, i) => _SidebarItem(
                index: i,
                title: stepTitles[i],
                isActive: i == currentIndex,
                isCompleted: isStepCompleted(i),
                onTap: () => onStepTap(i),
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
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  final int index;
  final String title;
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
                isActive: isActive,
                isCompleted: isCompleted,
                onDark: true,
              ),
              Expanded(
                child: Text(
                  title,
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
  const _StepTopBar({
    required this.compact,
    required this.stepTitles,
    required this.currentIndex,
    required this.isStepCompleted,
    required this.onStepTap,
  });

  /// true = ย่อเหลือบรรทัดเดียว (ตอนเลื่อนเนื้อหาลง)
  final bool compact;
  final List<String> stepTitles;
  final int currentIndex;
  final bool Function(int index) isStepCompleted;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final total = stepTitles.length;
    final current = currentIndex;
    final nextTitle = current + 1 < total ? stepTitles[current + 1] : null;

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
                    '${current + 1}/$total',
                    style: AppTextStyles.bold.copyWith(
                      fontSize: 12,
                      color: RegV2Colors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    stepTitles[current],
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
                _ProgressRing(current: current + 1, total: total),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'ขั้นตอนที่ ${current + 1} จาก $total',
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 12,
                          letterSpacing: 0.2,
                          color: RegV2Colors.primary,
                        ),
                      ),
                      Text(
                        stepTitles[current],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bold.copyWith(
                          fontSize: 18,
                          color: RegV2Colors.text,
                        ),
                      ),
                      Text(
                        nextTitle == null
                            ? 'ขั้นตอนสุดท้าย'
                            : 'ถัดไป: $nextTitle',
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
              for (var i = 0; i < total; i++)
                Expanded(
                  child: _StepSegment(
                    label: '${i + 1}. ${stepTitles[i]}',
                    isActive: i == current,
                    isDone: i < current || isStepCompleted(i),
                    onTap: () => onStepTap(i),
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
    required this.isActive,
    required this.isCompleted,
    this.onDark = false,
  });

  final int index;
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
