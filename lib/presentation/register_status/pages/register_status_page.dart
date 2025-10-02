import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/check_register_status_bloc/check_register_status_bloc.dart';
import 'package:rodzendai_form/presentation/splash/views/register_status_list.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/text_form_field_customer.dart';

class RegisterStatusPage extends StatefulWidget {
  const RegisterStatusPage({super.key});

  @override
  State<RegisterStatusPage> createState() => _RegisterStatusPageState();
}

class _RegisterStatusPageState extends State<RegisterStatusPage> {
  late CheckRegisterStatusBloc _checkRegisterStatusBloc;
  late GlobalKey<FormState> formkey;
  late TextEditingController idCardNumberController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _checkRegisterStatusBloc = CheckRegisterStatusBloc();
    formkey = GlobalKey<FormState>();
    idCardNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _checkRegisterStatusBloc.close();
    formkey.currentState?.dispose();
    idCardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _checkRegisterStatusBloc,
      child: Scaffold(
        appBar: _buildAppbar(context),
        backgroundColor: AppColors.white,
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: AppShadow.primaryShadow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            'ค้นหาสถานะการจอง',
                            style: TextStyle(
                              fontSize: 22.4,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(
                            color: AppColors.secondary.withOpacity(0.16),
                            thickness: 1,
                          ),
                          SizedBox.shrink(),
                          TextFormFiledCustom(
                            label: 'หมายเลขบัตรประชาชนผู้ป่วย',
                            hintText: 'กรอกเลขบัตรประชาชน 13 หลัก',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                            controller: idCardNumberController,
                            keyboardType: TextInputType.number,
                            validator: Validators.validateIdCardNumber,
                          ),
                          SizedBox.shrink(),
                          TextFormFiledCustom(
                            label: 'วันที่เดินทาง',
                            hintText: 'เลือกวันที่เดินทาง',
                            isReadOnly: true,
                            onTap: () async {
                              var results = await showCalendarDatePicker2Dialog(
                                context: context,
                                config:
                                    CalendarDatePicker2WithActionButtonsConfig(
                                      selectedDayHighlightColor:
                                          AppColors.primary,
                                      daySplashColor: AppColors.primary
                                          .withOpacity(0.2),
                                    ),
                                dialogSize: const Size(325, 400),
                                value: [_selectedDate],

                                borderRadius: BorderRadius.circular(8),
                                dialogBackgroundColor: AppColors.white,
                              );
                              if (results == null) return;
                              setState(() {
                                _selectedDate = results.first;
                              });
                            },
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                            controller: TextEditingController(
                              text: _selectedDate == null
                                  ? ''
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year + 543}',
                            ),
                            validator: Validators.validateTravelDate,
                          ),
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child:
                                BlocBuilder<
                                  CheckRegisterStatusBloc,
                                  CheckRegisterStatusState
                                >(
                                  builder: (context, state) {
                                    return ButtonCustom(
                                      text: 'ค้นหา',
                                      onPressed:
                                          state is! CheckRegisterStatusLoading
                                          ? _requestRegisterStatus
                                          : null,
                                      isLoading:
                                          state is CheckRegisterStatusLoading,
                                    );
                                  },
                                ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    BlocBuilder<
                      CheckRegisterStatusBloc,
                      CheckRegisterStatusState
                    >(
                      builder: (context, state) {
                        switch (state) {
                          case CheckRegisterStatusInitial():
                          case CheckRegisterStatusLoading():
                          case CheckRegisterStatusFailure():
                            return SizedBox.shrink();
                          case CheckRegisterStatusSuccess():
                            return RegisterStatusList(
                              patientTransports: state.data,
                            );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              context.go('/');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Icon(Icons.arrow_back, color: AppColors.white, size: 18),
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
          Spacer(),
          Text(
            'บริการรถรับ-ส่งผู้ป่วย',
            style: AppTextStyles.bold
                .copyWith(fontSize: 20)
                .copyWith(color: AppColors.white),
          ),
          Spacer(),
        ],
      ),
      backgroundColor: AppColors.primary,
    );
  }

  void _requestRegisterStatus() {
    if (formkey.currentState?.validate() == false) {
      return;
    }

    // ส่งข้อมูลไปยัง Bloc
    _checkRegisterStatusBloc.add(
      CheckRegisterStatusRequestEvent(
        idCardNumber: idCardNumberController.text,
        travelDate: _selectedDate!,
      ),
    );
  }
}
