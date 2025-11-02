String? IsValidPassword(String password) {
    // must have at least 8 characters
    if (password.length < 8) {
      return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
    }

    // must have a uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return "كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل";
    }

    // must have a lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return "كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل";
    }

    // must have a number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return "كلمة المرور يجب أن تحتوي على رقم واحد على الأقل";
    }

    // special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل";
    }

    return null;
  }