class Api {
  static get Admin {
    return Admin();
  }
}

class Admin {
  static getSettings() {
    return "api/admin/getSettings";
  }
}

class x {
  x() {
    Api.Admin.getSettings();
  }
}
