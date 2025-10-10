import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/data_patient_bloc/data_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_patient_info.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';

class RegisterToClaimYourRightsPage extends StatefulWidget {
  const RegisterToClaimYourRightsPage({super.key});

  @override
  State<RegisterToClaimYourRightsPage> createState() =>
      _RegisterToClaimYourRightsPageState();
}

class _RegisterToClaimYourRightsPageState
    extends State<RegisterToClaimYourRightsPage> {
  late RegisterToClaimYourRightsProvider _registerProvider;
  late DataPatientBloc _dataPatientBloc;
  @override
  void initState() {
    super.initState();
    _registerProvider = RegisterToClaimYourRightsProvider();
    _dataPatientBloc = DataPatientBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dataPatientBloc..add(LoadDataPatientsEvent()),
      child: ChangeNotifierProvider.value(
        value: _registerProvider,
        child: _view(),
      ),
    );
  }

  Scaffold _view() {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBarCustomer(title: 'ลงทะเบียนรับสิทธิ์'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              spacing: 16,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'หน้าลงทะเบียนรับสิทธิ์ - กำลังพัฒนา',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FormPatientInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
