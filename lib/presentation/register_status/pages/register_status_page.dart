import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_shadow.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/core/utils/toast_helper.dart';
import 'package:rodzendai_form/core/utils/validators.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/check_register_status_bloc/check_register_status_bloc.dart';
import 'package:rodzendai_form/presentation/splash/views/register_status_list.dart';
import 'package:rodzendai_form/repositories/firebase_repository.dart';
import 'package:rodzendai_form/widgets/appbar_customer.dart';
import 'package:rodzendai_form/widgets/button_custom.dart';
import 'package:rodzendai_form/widgets/text_form_field_custom.dart';

class RegisterStatusPage extends StatefulWidget {
  const RegisterStatusPage({super.key, this.nationalId, this.date});
  final String? nationalId;
  final String? date;

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

    _checkRegisterStatusBloc = CheckRegisterStatusBloc(
      firebaseRepository: locator<FirebaseRepository>(),
    );
    formkey = GlobalKey<FormState>();
    idCardNumberController = TextEditingController();

    if (widget.nationalId != null && widget.nationalId!.isNotEmpty) {
      idCardNumberController.text = widget.nationalId!;
    }
    if (widget.date != null && widget.date!.isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.date!);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (idCardNumberController.text.isNotEmpty && _selectedDate != null) {
        _requestRegisterStatus();
      }
    });
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
        appBar: AppBarCustomer(title: 'บริการรถรับ-ส่งผู้ป่วย'),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topCenter,
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: Form(
                key: formkey,
                child: Column(
                  spacing: 24,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
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
                          TextFormFielddCustom(
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
                          // TextFormFielddCustom(
                          //   label: 'วันที่เดินทาง',
                          //   hintText: 'เลือกวันที่เดินทาง',
                          //   isReadOnly: true,
                          //   onTap: () async {
                          //     var results = await showCalendarDatePicker2Dialog(
                          //       context: context,
                          //       config:
                          //           CalendarDatePicker2WithActionButtonsConfig(
                          //             selectedDayHighlightColor:
                          //                 AppColors.primary,
                          //             daySplashColor: AppColors.primary
                          //                 .withOpacity(0.2),
                          //             calendarType:
                          //                 CalendarDatePicker2Type.single,
                          //             okButtonTextStyle: AppTextStyles.regular
                          //                 .copyWith(color: AppColors.primary),
                          //             cancelButtonTextStyle:
                          //                 AppTextStyles.regular,
                          //             okButton: Text(
                          //               'ตกลง',
                          //               style: AppTextStyles.regular.copyWith(
                          //                 color: AppColors.primary,
                          //               ),
                          //             ),
                          //             cancelButton: Text(
                          //               'ยกเลิก',
                          //               style: AppTextStyles.regular.copyWith(
                          //                 color: AppColors.textLight,
                          //               ),
                          //             ),
                          //           ),
                          //       dialogSize: const Size(325, 400),
                          //       value: [_selectedDate],

                          //       borderRadius: BorderRadius.circular(8),
                          //       dialogBackgroundColor: AppColors.white,
                          //     );
                          //     if (results == null) return;
                          //     setState(() {
                          //       _selectedDate = results.first;
                          //     });
                          //   },
                          //   suffixIcon: Icon(Icons.calendar_today, size: 18),
                          //   controller: TextEditingController(
                          //     text: _selectedDate == null
                          //         ? ''
                          //         : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year + 543}',
                          //   ),
                          //   validator: Validators.validateTravelDate,
                          // ),
                          //SizedBox(height: 8),
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
                              patientTransports: state.data ?? [],
                            );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _requestRegisterStatus() {
    if (formkey.currentState?.validate() == false) {
      ToastHelper.showValidationError(context: context);
      return;
    }

    // ส่งข้อมูลไปยัง Bloc
    _checkRegisterStatusBloc.add(
      CheckRegisterStatusRequestEvent(
        idCardNumber: idCardNumberController.text,
        //travelDate: _selectedDate!,
      ),
    );
  }
}
