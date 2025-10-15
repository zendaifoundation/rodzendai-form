part of 'register_to_claim_your_rights_bloc.dart';

sealed class RegisterToClaimYourRightsEvent extends Equatable {
  const RegisterToClaimYourRightsEvent();

  @override
  List<Object?> get props => [];
}

class RegisterToClaimYourRightsRequestEvent
    extends RegisterToClaimYourRightsEvent {
  const RegisterToClaimYourRightsRequestEvent({
    required this.data,
    this.documentFiles,
  });

  final Map<String, dynamic> data;
  final List<UploadedFile>? documentFiles;

  @override
  List<Object?> get props => [data, documentFiles];
}
