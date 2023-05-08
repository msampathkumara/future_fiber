import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../ns_icons_icons.dart';
import '../C/DB/HiveClass.dart';
import 'PermissionsEnum.dart';

enum Production { All, EC__SIX, AERO__SIX, FIBRE_LIGHT, Machine_Shop, PULTRUSION, TACO, None }

enum StandardProductions { All, EC__SIX, AERO__SIX, FIBRE_LIGHT, Machine_Shop, PULTRUSION, TACO }

enum SortByItem { id, mo, oe, finished, dir, uptime, file, sheet, production, isRed, isRush, inPrint, isError, isGr, isSk, isHold, delete, reNamed, progress, fileVersion }

enum Status { All, Sent, Cancel, Done }

enum Type { All, QA, QC }

enum TicketFlagTypes { RED, GR, RUSH, SK, HOLD, CROSS }

enum Filters { isRed, isRush, inPrint, isError, isGr, isSk, isHold, none, isQc, isQa, haveCpr, haveKit }

enum Collection { User, Ticket, Any }

enum TicketAction { startProduction }

extension ProductionExtension on Production {
  String getValue() {
    return (this).toString().split('.').last.replaceAll("__", "-").replaceAll('_', " ").trim();
  }

  bool equalCaseInsensitive(String production) {
    return getValue().toLowerCase().trim() == production.toLowerCase().trim();
  }
}

extension StandardProductionsExtension on StandardProductions {
  String getValue() {
    return (this).toString().split('.').last.replaceAll("__", "-").replaceAll('_', " ").trim();
  }

  bool equalCaseInsensitive(String production) {
    return getValue().toLowerCase().trim() == production.toLowerCase().trim();
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

  getIcon() {
    return {
      TicketFlagTypes.RED: Icons.tour_rounded,
      TicketFlagTypes.GR: NsIcons.gr,
      TicketFlagTypes.RUSH: Icons.flash_on_rounded,
      TicketFlagTypes.SK: NsIcons.sk,
      TicketFlagTypes.HOLD: NsIcons.stop
    }[this];
  }
}

enum ActionMenuItems { Share, Edit, BlueBook, ShippingSystem, CS, Finish, Info }

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

extension F on Box {
  putObject(HiveClass value) async {
    Object id = value.id != -1 ? value.id : uuid.v4();
    // print(id);
    await put(id, value);
  }

  Future<List<HiveClass>> putMany(List<HiveClass> list, {Function(int, HiveClass)? onItemAdded, Null Function(List list)? afterAdd}) async {
    for (var element in list.asMap().entries) {
      await putObject(element.value);
      if (onItemAdded != null) {
        await onItemAdded(element.key, element.value);
      }
    }
    if (afterAdd != null) {
      afterAdd(list);
    }
    return Future(() => list);
  }

  Iterable getAll() {
    return values.toList();
  }
}
//
// enum ns {
//   TAB,
//   ALERT_MANAGER,
//   SHORT_MANAGER_RESPOND,
//   SHORT_MANAGER_DELETE,
//   UPLOAD_TICKET,
//   UPLOAD_STANDARD_FILES,
//   DELETE_TICKETS,
//   DELETE_COMPLETED_TICKETS,
//   DELETE_STANDARD_FILES,
//   CANCEL_ROUTE,
//   PRINTING,
//   USER_MANAGER,
//   DATABASE_UPLOAD,
//   WEB,
//   SEND_TO_PRINTING,
//   EMAIL_PDF,
//   EDIT_ANY_PDF,
//   Edit_PDF_IN_STANDED_LIB,
//   QC,
//   EDIT_COMPLETED_TICKET,
//   ADD_MISSING_DATES,
//   ADD_CPR,
//   SEND_ANY_CPR,
//   RECEIVE_ANY_CPR,
//   USER_ADD_USER,
//   TICKET_RENAME_MO,
//   CPR,
//   PRODUCTION_POOL,
//   HR,
//   BLUE_BOOK,
//   J109,
//   SET_RED_FLAG,
//   STOP_PRODUCTION,
//   SET_GR,
//   SET_RUSH,
//   FINISH_TICKET,
//   SET_CROSS_PRODUCTION,
//   SHARE_TICKETS,
//   SHIPPING_SYSTEM,
//   CS,
//   CHANGE_STANDARD_FILES_FACTORY,
//   DELETE_USER,
//   UPDATE_USER,
//   SET_USER_PERMISSIONS,
//   DEACTIVATE_USERS,
//   UNLOCK_USERS,
//   SET_ID_CARD,
//   REMOVE_ID_CARD,
//   PENDING_TO_FINISH,
//   SHEET_DATA,
//   ADMIN,
//   STANDARD_FILES,
//   CHECK_CPR_ITEMS,
//   SCAN_READY_KITS,
//   ORDER_KITS,
//   SEND_KITS,
//   RESET_PASSWORD,
//   MATERIAL_MANAGEMENT
// }

extension PermissionsExtension on NsPermissions {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension NumberExtention on num {
  String timeFromHours() {
    var d = Duration(minutes: (this * 60).toInt());
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}

extension StringContainsInArrayExtension on String {
  bool isJson() {
    try {
      return true;
    } on FormatException {
      return false;
    }
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

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
      case 'readying':
        return Colors.deepPurple;
      case 'ready':
        return Colors.amber;

      case 'pending':
        return Colors.red;

      case 'sent':
        return Colors.green;

      case 'received':
        return Colors.blue;

      case 'order':
        return Colors.purple;

      case 'normal':
        return Colors.green;

      case 'urgent':
        return Colors.red;

      case 'good':
        return Colors.green;

      case 'excellent':
        return Colors.blue;

      case 'reject':
        return Colors.red;
    }

    return Colors.red;
  }
}

extension ListExt<T> on List<T> {
  List<T> without(List<T> withoutList) {
    return where((x) => withoutList.contains(x) == false).toList();
  }
}

extension TextEditingControllerExt on TextEditingController {
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension DateTimeExtension on DateTime? {
  bool? isAfterOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      return date.isAfter(dateTime);
    }
    return null;
  }

  bool? isBeforeOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      return date.isBefore(dateTime);
    }
    return null;
  }

  bool? isNotBetween(DateTime fromDateTime, DateTime toDateTime) {
    return !(isBetween(fromDateTime, toDateTime))!;
  }

  bool? isBetween(DateTime fromDateTime, DateTime toDateTime) {
    final date = this;
    if (date != null) {
      final isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
      final isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
      return isAfter && isBefore;
    }
    return null;
  }
}
