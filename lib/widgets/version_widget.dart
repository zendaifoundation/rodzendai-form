import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/home_page/blocs/version_info/version_info_bloc.dart';

class VersionViewWidget extends StatelessWidget {
  final bool showInNewLine; // เพิ่มพารามิเตอร์นี้

  const VersionViewWidget({
    super.key,
    this.showInNewLine = false,
  }); // ตั้งค่าค่าเริ่มต้นเป็น false

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionInfoBloc, VersionInfoState>(
      builder: (context, state) {
        String? version = '0.0.0';
        String? buildNumber = '0';
        if (state is VersionInfoSuccess) {
          version = state.packageInfo.version;
          buildNumber = state.packageInfo.buildNumber;
        }
        // ถ้า showInNewLine เป็น true ก็เพิ่ม \n ในข้อความ
        final text = showInNewLine
            ? 'version\n$version ($buildNumber)'
            : 'version $version ($buildNumber)';

        return Text(
          text,
          style: AppTextStyles.regular.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
