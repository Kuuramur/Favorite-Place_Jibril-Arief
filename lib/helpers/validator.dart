class Validator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is Required";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is Required";
    }
    if (!RegExp('[a-zA-Z0-9.-]+(.[a-zA-Z]{2,})+').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is Required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }
}
