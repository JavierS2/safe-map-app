class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "El nombre es obligatorio";
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$').hasMatch(value)) {
      return "El nombre no puede contener números";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Ingresa un correo";
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
      return "Correo inválido";
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Ingresa un número";
    // expect exactly 10 digits (without the +57 prefix)
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Formato inválido (Ej: 3001234567)";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Ingresa una contraseña";

    bool hasUpper = value.contains(RegExp(r'[A-Z]'));
    bool hasLower = value.contains(RegExp(r'[a-z]'));
    bool hasDigit = value.contains(RegExp(r'[0-9]'));
    bool hasSpecial = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    bool validLength = value.length >= 8;

    if (!hasUpper) return "Debe incluir mayúsculas";
    if (!hasLower) return "Debe incluir minúsculas";
    if (!hasDigit) return "Debe incluir números";
    if (!hasSpecial) return "Debe incluir caracteres especiales";
    if (!validLength) return "Debe tener al menos 8 caracteres";

    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return "Ingresa fecha de nacimiento";
    if (!RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(value)) {
      return "Formato inválido";
    }
    return null;
  }

  static String? confirmPassword(String? pass, String? confirm) {
    if (confirm == null || confirm.isEmpty) return "Confirma la contraseña";
    if (pass != confirm) return "Las contraseñas no coinciden";
    return null;
  }
}
