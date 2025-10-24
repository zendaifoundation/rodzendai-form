import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register/interfaces/patient_type.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/box_upload_multi_file_widget.dart';
import 'package:rodzendai_form/presentation/register/widgets/form_header.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/widgets/base_card_container.dart';
import 'package:rodzendai_form/widgets/required_label.dart';

class FormDoument extends StatelessWidget {
  const FormDoument({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<RegisterToClaimYourRightsProvider, PatientType>(
      selector: (_, provider) => provider.patientTypeSelected,
      builder: (context, patientType, child) {
        return BaseCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FormHeaderWidget(title: 'เอกสาร'),
              ...switch (patientType) {
                PatientType.elderly => [_idCardDocument()], //ผู้สูงอายุ
                PatientType.disabled => [_idCardDocument()], //คนพิการ
                PatientType.hardship => [
                  _idCardDocument(),
                  Divider(
                    color: AppColors.secondary.withOpacity(0.16),
                    thickness: 1,
                  ),
                  _buildThaiStateWelfareCard(),
                  Divider(
                    color: AppColors.secondary.withOpacity(0.16),
                    thickness: 1,
                  ),
                  _buildOtherDocuments(),
                ], //ผู้มีความลำบาก
              },
            ],
          ),
        );
      },
    );
  }

  Column _idCardDocument() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(text: 'บัตรประชาชน', isRequired: true),
        Selector<RegisterToClaimYourRightsProvider, UploadedFile?>(
          selector: (_, provider) => provider.idCardFiles,
          builder: (context, value, child) => BoxUploadFileWidget(
            labelText: 'อัปโหลดบัตรประชาชน',
            initialValue: value,
            onFilesSelected: (file) {
              context.read<RegisterToClaimYourRightsProvider>().setIdCardFiles(
                file,
              );
            },
            validator: (UploadedFile? file) {
              if (file == null) {
                return 'กรุณาอัปโหลดไฟล์บัตรประชาชน';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Column _buildOtherDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(text: 'เอกสารอื่นๆ', isRequired: false),
        Selector<RegisterToClaimYourRightsProvider, List<UploadedFile>>(
          selector: (_, provider) => provider.otherFiles,
          builder: (context, otherFiles, child) => BoxUploadMultiFileWidget(
            labelText: 'อัปโหลดเอกสารอื่นๆ',
            initialValue: otherFiles,
            maxFile: 5,
            onFilesSelected: (file) {
              context.read<RegisterToClaimYourRightsProvider>().setOtherFiles(
                file,
              );
            },
            isRequired: false,
          ),
        ),
      ],
    );
  }

  Column _buildThaiStateWelfareCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(text: 'บัตรสวัสดิการแห่งรัฐ', isRequired: false),
        Selector<RegisterToClaimYourRightsProvider, UploadedFile?>(
          selector: (_, provider) => provider.thaiStateWelfareCardFiles,
          builder: (context, thaiStateWelfareCardFiles, child) =>
              BoxUploadFileWidget(
                labelText: 'อัปโหลดบัตรสวัสดิการแห่งรัฐ',
                isRequired: false,
                initialValue: thaiStateWelfareCardFiles,
                onFilesSelected: (file) {
                  context
                      .read<RegisterToClaimYourRightsProvider>()
                      .setThaiStateWelfareCardFiles(file);
                },
              ),
        ),
      ],
    );
  }
}
