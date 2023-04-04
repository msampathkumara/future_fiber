class Validations {
  static bool isValidEmail(email) {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  static String? epfValidation(String? epf, {String ifEmpty = "Enter NIC", String ifInvalid = "Enter valid NIC"}) {
    if (epf == null || epf.isEmpty) {
      return ifEmpty;
    }
    return RegExp('[0-9]').hasMatch(epf) ? null : ifInvalid;
  }

  static String? phoneNumberValidation(String? phoneNumber, {String ifEmpty = "Enter Phone Number", String ifInvalid = "Enter valid Phone Number", isRequired = true}) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return (isRequired) ? ifEmpty : null;
    }
    return RegExp(r"^(?:7|0|(?:\+94))[0-9]{9,10}$").hasMatch(phoneNumber) ? null : ifInvalid;
  }

  static String? emailValidate(String? email, {String ifEmpty = "Enter email Number", String ifInvalid = "Enter valid email address", isRequired = true}) {
    if (email == null || email.isEmpty) {
      return (isRequired) ? ifEmpty : null;
    }
    return RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(email)
        ? null
        : ifInvalid;
  }

  static final RegExp nameRegExp = RegExp('[a-zA-Z]');

  static String? nameValidate(String? name, {int? maxLength, int? minLength, String? ifEmpty, String? ifInvalid}) {
    if (name == null || name.isEmpty) {
      return ifEmpty ?? "Enter name";
    }
    return RegExp(r"^\s*([A-Za-z]{1,}([.,] | [-']|))+[A-Za-z]+.?s*$", caseSensitive: false, unicode: true, dotAll: true).hasMatch(name) ? null : (ifInvalid ?? "Enter valid name");
  }

  static String? nic(String? nic, {String ifEmpty = "Enter NIC", String ifInvalid = "Enter valid NIC"}) {
    if (nic == null || nic.isEmpty) {
      return ifEmpty;
    }
    print('nic');
    return RegExp(r"(?=(\d{9}[x|X|v|V])|\d{12})(?=^(?:19|20)?\d{2}(?:[0-35-8]\d\d(?<!(?:000|500|36[7-9]|3[7-9]\d|86[7-9]|8[7-9]\d)))\d((\d{3}[vVxX]{1})$|\d{4}$))").hasMatch(nic)
        ? null
        : (ifInvalid);
  }
}
