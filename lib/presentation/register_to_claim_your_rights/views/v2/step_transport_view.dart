import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rodzendai_form/presentation/register/interfaces/transport_ability.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/interfaces/register_v2_options.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/providers/register_to_claim_your_rights_v2_provider.dart';
import 'package:rodzendai_form/presentation/register_to_claim_your_rights/widgets/v2/choice_card_group.dart';

/// Step 2 — ความสามารถในการเดินทาง (`vehicle_request`)
class StepTransportView extends StatelessWidget {
  const StepTransportView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterToClaimYourRightsV2Provider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        ChoiceCardGroup<TransportAbility>(
          label: 'ผู้ป่วยเดินทางแบบใดได้?',
          requiredMessage: 'กรุณาเลือกรูปแบบการเดินทาง',
          horizontalBreakpoint: 480,
          value: provider.transportAbility,
          onChanged: provider.setTransportAbility,
          options: [
            for (final ability in TransportAbility.values)
              ChoiceCardOption(
                value: ability,
                title: ability.titleV2,
                summary: ability.summaryV2,
                icon: ability.iconV2,
              ),
          ],
        ),
        // const InfoBox(
        //   text: 'เจ้าหน้าที่ตรวจสอบความเหมาะสมของรถก่อนยืนยันบริการ',
        // ),
      ],
    );
  }
}
