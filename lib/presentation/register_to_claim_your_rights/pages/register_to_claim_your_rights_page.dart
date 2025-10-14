import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/blocs/data_patient_bloc/data_patient_bloc.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_address_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_companion_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_current_address_info.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/views/form_patient_info.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';

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
                FormPatientInfo(registerProvider: _registerProvider),
                FormAddressInfo(),
                FormCurrentAddressInfo(),
                FormCompanionInfo(),
                SizedBox.shrink(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ButtonCustom(
                    text: 'ลงทะเบียน',
                    onPressed: () async {
                      //todo
                    },
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
