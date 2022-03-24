import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'HiveClass.dart';

enum Production { All, Upwind, OD, Nylon, OEM, None }
enum SortByItem { id, mo, oe, finished, dir, uptime, file, sheet, production, isRed, isRush, inPrint, isError, isGr, isSk, isHold, delete, reNamed, progress, fileVersion }
enum Status { All, Sent, Cancel, Done }
enum Type { All, QA, QC }
enum TicketFlagTypes { RED, GR, RUSH, SK, HOLD }
enum Filters { isRed, isRush, inPrint, isError, isGr, isSk, isHold, none, isSort, crossPro }
enum Collection { User, Ticket, Any }

extension ProductionExtension on Production {
  String getValue() {
    return (this).toString().split('.').last;
  }
}

extension ParseToString on Production {
  String toShortString() {
    return (this).toString().split('.').last;
  }
}

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
    print(id);
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
  REMOVE_ID_CARD
}

extension PermissionsExtension on Permissions {
  String getValue() {
    return (this).toString().split('.').last;
  }
}
