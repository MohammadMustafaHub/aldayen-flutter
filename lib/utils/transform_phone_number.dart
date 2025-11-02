String? TransformPhoneNumber(String phoneNumber) {
  if (phoneNumber.startsWith('964')) {
    phoneNumber = phoneNumber.substring(3);
  }

  if (phoneNumber.startsWith("+964")) {
    phoneNumber = phoneNumber.substring(4);
  }

  if (phoneNumber.startsWith("0")) {
    phoneNumber = phoneNumber.substring(1);
  }

  if (phoneNumber.length != 10 || !phoneNumber.startsWith("7")) {
    return null;
  }

  return "964$phoneNumber";
}

// "+96407821057415"
