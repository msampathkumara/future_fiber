enum Production { All, Upwind, OD, Nylon, OEM }
enum SortByItem { id, mo, oe, finished, dir, uptime, file, sheet, production, isRed, isRush, inPrint, isError, isGr, isSk, isHold, delete, reNamed, progress, fileVersion }
enum Status { All, Sent, Cancel, Done }
enum Type {All, QA, QC }


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

enum ActionMenuItems{Share,Edit,BlueBook,ShippingSystem,CS}
extension ActionMenuItemExtension on ActionMenuItems {
  String getValue() {
    return (this).toString().split('.').last;
  }
}
