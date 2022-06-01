import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'HiveClass.dart';

enum Production { All, Upwind, OD, Nylon, OEM, _38_Upwind, _38_Nylon, _38_OEM, _38_OD, None }
enum SortByItem { id, mo, oe, finished, dir, uptime, file, sheet, production, isRed, isRush, inPrint, isError, isGr, isSk, isHold, delete, reNamed, progress, fileVersion }
enum Status { All, Sent, Cancel, Done }
enum Type { All, QA, QC }
enum TicketFlagTypes { RED, GR, RUSH, SK, HOLD, CROSS }

enum Filters { isRed, isRush, inPrint, isError, isGr, isSk, isHold, none, isSort, isCrossPro, isQc, isQa }

enum Collection { User, Ticket, Any }

extension ProductionExtension on Production {
  String getValue() {
    return (this).toString().split('.').last.replaceAll('_', " ").trim();
  }

  bool equalCaseInsensitive(String production) {
    return (this).toString().split('.').last.replaceAll('_', " ").trim().toLowerCase() == production.toLowerCase().trim();
  }
}

// extension ParseToString on Production {
//   String toShortString() {
//     return (this).toString().split('.').last;
//   }
// }

extension SortByExtension on SortByItem {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension StatusExtension on Status {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension TypeToString on Type {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension TicketFlagTypesToString on TicketFlagTypes {
  String getValue() {
    return (this).toString().split('.').last.toLowerCase();
  }
}

enum ActionMenuItems { Share, Edit, BlueBook, ShippingSystem, CS, Finish }

extension ActionMenuItemExtension on ActionMenuItems {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension FiltersExtension on Filters {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

var uuid = const Uuid();

extension f on Box {
  putObject(HiveClass value) {
    Object id = value.id != -1 ? value.id : uuid.v4();
    // print(id);
    put(id, value);
  }

  putMany(List<HiveClass> list) {
    for (var element in list) {
      putObject(element);
    }
  }

  Iterable getAll() {
    return values.toList();
  }
}
enum Permissions {
  TAB,
  ALERT_MANAGER,
  SHORT_MANAGER_RESPOND,
  SHORT_MANAGER_DELETE,
  UPLOAD_TICKET,
  UPLOAD_STANDARD_FILES,
  DELETE_TICKETS,
  DELETE_COMPLETED_TICKETS,
  DELETE_STANDARD_FILES,
  CANCEL_ROUTE,
  PRINTING,
  USER_MANAGER,
  DATABASE_UPLOAD,
  WEB,
  SEND_TO_PRINTING,
  EMAIL_PDF,
  EDIT_ANY_PDF,
  Edit_PDF_IN_STANDED_LIB,
  QC,
  EDIT_COMPLETED_TICKET,
  ADD_MISSING_DATES,
  ADD_CPR,
  SEND_ANY_CPR,
  RECEIVE_ANY_CPR,
  USER_ADD_USER,
  TICKET_RENAME_MO,
  CPR,
  PRODUCTION_POOL,
  HR,
  BLUE_BOOK,
  J109,
  SET_RED_FLAG,
  STOP_PRODUCTION,
  SET_GR,
  SET_RUSH,
  FINISH_TICKET,
  SET_CROSS_PRODUCTION,
  SHARE_TICKETS,
  SHIPPING_SYSTEM,
  CS,
  CHANGE_STANDARD_FILES_FACTORY,
  DELETE_USER,
  UPDATE_USER,
  SET_USER_PERMISSIONS,
  DEACTIVATE_USERS,
  SET_ID_CARD,
  REMOVE_ID_CARD,
  PENDING_TO_FINISH,
  SHEET_DATA,
  ADMIN,
  STANDARD_FILES,
  CHECK_CPR_ITEMS,
  SCAN_READY_KITS,
  ORDER_KITS,
  SEND_KITS,
  RESET_PASSWORD
}

extension PermissionsExtension on Permissions {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension StringContainsInArrayExtension on String {
  bool containsInArrayIgnoreCase(List<String?> list) {
    return list.where((element) => element != null && element.toLowerCase().contains(toLowerCase())).isNotEmpty;
  }

  bool containsInArray(List<String> list) {
    return list.where((element) => element.contains(this)).isNotEmpty;
  }

  bool isReady({trim = false, caseInsensitive = true}) {
    String t = this;
    if (trim) {
      t = this.trim();
    }
    if (caseInsensitive) {
      t = toLowerCase();
    }
    return t == 'ready';
  }

  bool equalIgnoreCase(String text) {
    return toLowerCase() == text.toLowerCase();
  }

  bool containsIgnoreCase(String text) {
    return toLowerCase().contains(text.toLowerCase());
  }

  MaterialColor getColor() {
    String t = trim().toLowerCase();
    switch (t) {
      case 'ready':
        return Colors.amber;
        break;
      case 'pending':
        return Colors.red;
        break;
      case 'sent':
        return Colors.green;
        break;
      case 'received':
        return Colors.blue;
        break;
      case 'order':
        return Colors.purple;
        break;
    }

    return Colors.red;
  }
}
