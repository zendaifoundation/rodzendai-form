import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/utils/env_helper.dart';
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
    return Selector<RegisterToClaimYourRightsProvider, PatientType?>(
      selector: (_, provider) => provider.patientTypeSelected,
      builder: (context, patientType, child) {
        if (patientType == null) {
          return const SizedBox.shrink();
        }
        return BaseCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Selector<RegisterToClaimYourRightsProvider, bool>(
                selector: (_, provider) => provider.uploadDocumentLater,
                builder: (context, uploadDocumentLater, child) {
                  return FormHeaderWidget(
                    title: 'เอกสาร',
                    value: uploadDocumentLater,
                    subTitle: 'อัปโหลดเอกสารภายหลัง',
                    onChanged: (bool? value) {
                      context
                          .read<RegisterToClaimYourRightsProvider>()
                          .setUploadDocumentLater(value ?? false);
                    },
                  );
                },
              ),
              Selector<RegisterToClaimYourRightsProvider, bool>(
                selector: (_, provider) => provider.uploadDocumentLater,
                builder: (context, uploadDocumentLater, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      ...switch (patientType) {
                        //ผู้สูงอายุ
                        PatientType.elderly => [
                          _idCardDocument(uploadDocumentLater),
                          _disabilityCardDocument(
                            uploadDocumentLater,
                            isRequired: false,
                            lable: 'บัตรผู้พิการ(ถ้ามี)',
                            desciption: 'บัตรผู้พิการ(ถ้ามี)',
                          ),
                          if (EnvHelper.customerCode == 'tessaban_saensuk')
                            _buildHouseRegistration(uploadDocumentLater),
                        ],
                        //คนพิการ
                        PatientType.disabled => [
                          _idCardDocument(uploadDocumentLater),
                          _disabilityCardDocument(uploadDocumentLater),
                          if (EnvHelper.customerCode == 'tessaban_saensuk')
                            _buildHouseRegistration(uploadDocumentLater),
                        ],
                        PatientType.hardship => [
                          //ผู้มีความลำบาก
                          _idCardDocument(uploadDocumentLater),
                          Divider(
                            color: AppColors.secondary.withOpacity(0.16),
                            thickness: 1,
                          ),
                          if (EnvHelper.customerCode == 'tessaban_saensuk')
                            _buildHouseRegistration(uploadDocumentLater),
                          _buildThaiStateWelfareCard(),
                          _buildOtherDocuments(),
                        ],
                      },

                      if (EnvHelper.customerCode == 'tessaban_angsila') ...[
                        Divider(
                          color: AppColors.secondary.withOpacity(0.16),
                          thickness: 1,
                        ),
                        _buildHouseRegistration(uploadDocumentLater),
                        Divider(
                          color: AppColors.secondary.withOpacity(0.16),
                          thickness: 1,
                        ),
                        _buildAddressConfirmation(uploadDocumentLater),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Column _idCardDocument(bool uploadDocumentLater) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(
          text: 'บัตรประชาชน',
          isRequired: uploadDocumentLater ? false : true,
        ),
        if (EnvHelper.customerCode == 'tessaban_angsila')
          Selector<RegisterToClaimYourRightsProvider, UploadedFile?>(
            selector: (_, provider) => provider.idCardFiles,
            builder: (context, value, child) => BoxUploadFileWidget(
              labelText: 'อัปโหลดบัตรประชาชน',
              initialValue: value,
              onFilesSelected: (file) {
                context
                    .read<RegisterToClaimYourRightsProvider>()
                    .setIdCardFiles(file);
              },
              isRequired: uploadDocumentLater ? false : true,
              validator: uploadDocumentLater
                  ? null
                  : (UploadedFile? file) {
                      if (file == null) {
                        return 'กรุณาอัปโหลดไฟล์บัตรประชาชน';
                      }
                      return null;
                    },
            ),
          )
        else
          Selector<RegisterToClaimYourRightsProvider, UploadedFile?>(
            selector: (_, provider) => provider.idCardFiles,
            builder: (context, value, child) => BoxUploadFileWidget(
              labelText: 'อัปโหลดบัตรประชาชน',

              initialValue: value,
              onFilesSelected: (file) {
                context
                    .read<RegisterToClaimYourRightsProvider>()
                    .setIdCardFiles(file);
              },
              isRequired: uploadDocumentLater ? false : true,
              validator: uploadDocumentLater
                  ? null
                  : (UploadedFile? file) {
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

  Column _disabilityCardDocument(
    bool uploadDocumentLater, {
    bool isRequired = true,
    String lable = 'บัตรผู้พิการ',
    String? desciption,
  }) {
    final required = isRequired && !uploadDocumentLater;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(text: lable, isRequired: required),
        Selector<RegisterToClaimYourRightsProvider, UploadedFile?>(
          selector: (_, provider) => provider.disabilityCardFiles,
          builder: (context, value, child) => BoxUploadFileWidget(
            labelText: 'อัปโหลดบัตรผู้พิการ',
            description: desciption,
            initialValue: value,

            onFilesSelected: (file) {
              context
                  .read<RegisterToClaimYourRightsProvider>()
                  .setDisabilityCardFiles(file);
            },
            isRequired: required,
            validator: required
                ? (UploadedFile? file) {
                    if (file == null) {
                      return 'กรุณาอัปโหลดไฟล์บัตรผู้พิการ';
                    }
                    return null;
                  }
                : null,
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

  Column _buildHouseRegistration(bool uploadDocumentLater) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(
          text: 'ทะเบียนบ้าน',
          isRequired: uploadDocumentLater ? false : true,
        ),
        Selector<RegisterToClaimYourRightsProvider, List<UploadedFile>>(
          selector: (_, provider) => provider.houseRegistrationFiles,
          builder: (context, value, child) => BoxUploadMultiFileWidget(
            labelText: 'อัปโหลดทะเบียนบ้าน',
            description:
                'ทะเบียนบ้านจำนวน 2 หน้า ได้แก่\nหน้าแรกที่แสดงบ้านเลขที่ และหน้าที่มีชื่อของผู้ขอรับสิทธิ์/ผู้ป่วย\n',
            initialValue: value,
            maxFile: 2,
            onFilesSelected: (files) {
              context
                  .read<RegisterToClaimYourRightsProvider>()
                  .setHouseRegistrationFiles(files);
            },
            isRequired: uploadDocumentLater ? false : true,
            validator: uploadDocumentLater
                ? null
                : (List<UploadedFile>? files) {
                    if (files == null || files.isEmpty) {
                      return 'กรุณาอัปโหลดไฟล์ทะเบียนบ้าน';
                    }
                    return null;
                  },
          ),
        ),
      ],
    );
  }

  Column _buildAddressConfirmation(bool uploadDocumentLater) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        RequiredLabel(text: 'ฟอร์มยืนยันที่อยู่', isRequired: false),
        Selector<RegisterToClaimYourRightsProvider, UploadedFile?>(
          selector: (_, provider) => provider.addressConfirmationFile,
          builder: (context, value, child) => BoxUploadFileWidget(
            labelText: 'อัปโหลดฟอร์มยืนยันที่อยู่',
            initialValue: value,
            onFilesSelected: (file) {
              context
                  .read<RegisterToClaimYourRightsProvider>()
                  .setAddressConfirmationFile(file);
            },
            isRequired: false,
          ),
        ),
      ],
    );
  }
}
