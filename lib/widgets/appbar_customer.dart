import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/dialog/app_dialogs.dart';

class AppBarCustomer extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCustomer({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarCustomer> createState() => _AppBarCustomerState();
}

class _AppBarCustomerState extends State<AppBarCustomer> {
  OverlayEntry? _accountOverlay;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          if (widget.showBackButton)
            InkWell(
              onTap: widget.onBackPressed ?? () => context.go('/home'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  spacing: 4,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 18,
                    ),
                    Text(
                      'กลับ',
                      style: AppTextStyles.regular.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.bold.copyWith(
                fontSize: 18,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actions: [
        if (authService.isAuthenticated) _buildAccountAction(authService),
      ],
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildAccountAction(AuthService authService) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = MediaQuery.sizeOf(context).width;
          final bool showAvatar = width >= 340;
          final bool showName = width >= 420;
          final displayName = authService.displayName ?? '-';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => _toggleOverlay(authService),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  if (showAvatar)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.white.withOpacity(0.15),
                      child: authService.pictureUrl != null
                          ? ClipOval(
                              child: Image.network(
                                authService.pictureUrl!,
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.white,
                            ),
                    )
                  else
                    const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppColors.white,
                    ),
                  if (showName)
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const Icon(
                    Icons.expand_more,
                    size: 18,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleOverlay(AuthService authService) {
    if (_accountOverlay != null) {
      _removeOverlay();
    } else {
      _showOverlay(authService);
    }
  }

  void _showOverlay(AuthService authService) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final topOffset = MediaQuery.of(context).padding.top + kToolbarHeight + 4;

    _accountOverlay = OverlayEntry(
      builder: (context) => _AccountOverlay(
        top: topOffset,
        authService: authService,
        onClose: _removeOverlay,
        onLogout: () => _handleLogout(authService),
      ),
    );

    overlay.insert(_accountOverlay!);
  }

  void _removeOverlay() {
    _accountOverlay?.remove();
    _accountOverlay = null;
  }

  Future<void> _handleLogout(AuthService authService) async {
    _removeOverlay();
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'ออกจากระบบ',
      message: 'คุณต้องการออกจากระบบหรือไม่?',
      confirmText: 'ออกจากระบบ',
      cancelText: 'ยกเลิก',
      confirmColor: AppColors.error,
    );

    if (confirmed == true) {
      await authService.logout();
      if (mounted) {
        context.go('/');
      }
    }
  }
}

class _AccountOverlay extends StatelessWidget {
  const _AccountOverlay({
    required this.top,
    required this.authService,
    required this.onClose,
    required this.onLogout,
  });

  final double top;
  final AuthService authService;
  final VoidCallback onClose;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final displayName = authService.displayName ?? '-';
    final userId = authService.userId ?? '-';
    final statusMessage = authService.profile?.statusMessage ?? '-';
    final pictureUrl = authService.pictureUrl;
    final hasToken = authService.getAccessToken() != null;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
          ),
        ),
        Positioned(
          top: top,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360, minWidth: 260),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.12),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: pictureUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  pictureUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 28,
                                color: AppColors.primary,
                              ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.bold.copyWith(fontSize: 17),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              statusMessage,
                              style: AppTextStyles.regular.copyWith(
                                fontSize: 13,
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonCustom(
                      text: 'ออกจากระบบ',
                      onPressed: onLogout,
                      backgroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTextStyles.medium.copyWith(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.regular.copyWith(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
