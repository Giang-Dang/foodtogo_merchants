import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/login_response_dto.dart';

class LoginResponseDTONotifier extends StateNotifier<LoginResponseDTO> {
  LoginResponseDTONotifier()
      : super(
          const LoginResponseDTO(
            isSuccess: false,
            errorMessage: "",
          ),
        );
}

final loginResponseDTOProvider =
    StateNotifierProvider<LoginResponseDTONotifier, LoginResponseDTO>(
  (ref) {
    return LoginResponseDTONotifier();
  },
);

