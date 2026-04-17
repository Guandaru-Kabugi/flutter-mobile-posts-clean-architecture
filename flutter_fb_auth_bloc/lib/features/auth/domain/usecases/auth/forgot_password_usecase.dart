import 'package:equatable/equatable.dart';

// ignore: avoid_types_as_parameter_names
abstract class ForgotPasswordUsecase <Type, Params> {
  Future<Type> call (Params params);
}
class ForgotPasswordParams extends Equatable{
  final String email;

  const ForgotPasswordParams({required this.email});
  @override
  List<Object?> get props => [email];

}