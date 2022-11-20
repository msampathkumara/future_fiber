class EndPoints {
  /// auto generated by smartwind server project
  /// 2022-11-19 07:11:01.440Z

  static const _ip = "/ip";
  static const _user_recoverPassword_sendOTP = "/user/recoverPassword/sendOTP";
  static const _user_recoverPassword_getUserByNic = "/user/recoverPassword/getUserByNic";
  static const _user_recoverPassword_validateOtp = "/user/recoverPassword/validateOtp";
  static const _user_recoverPassword_savePassword = "/user/recoverPassword/savePassword";
  static const _user_recoverPassword_sendOTPToAdmin = "/user/recoverPassword/sendOTPToAdmin";
  static const _user_login = "/user/login";
  static const _user_getUserData = "/user/getUserData";
  static const _user_setUserSection = "/user/setUserSection";
  static const _user_loginWithCookie = "/user/loginWithCookie";
  static const _user_loginWithCred = "/user/loginWithCred";
  static const admin_settings_getSettings = "admin/settings/getSettings";
  static const admin_settings_setSetting = "admin/settings/setSetting";
  static const admin_reloadTicketDB = "admin/reloadTicketDB";
  static const admin_reloadInMemoryDB = "admin/reloadInMemoryDB";
  static const admin_cleanReloadDevices = "admin/cleanReloadDevices";
  static const admin_updateStandard = "admin/updateStandard";
  static const admin_updateNowAt = "admin/updateNowAt";
  static const admin_doneKitting = "admin/doneKitting";
  static const admin_checkFile = "admin/checkFile";
  static const admin_updateUsers = "admin/updateUsers";
  static const admin_updateStandardLibUsage = "admin/updateStandardLibUsage";
  static const admin_updateProgress = "admin/updateProgress";
  static const admin_convertTickets = "admin/convertTickets";
  static const dashboard_settings_saveSailAverageTime = "dashboard/settings/saveSailAverageTime";
  static const dashboard_settings_getSailAverageTime = "dashboard/settings/getSailAverageTime";
  static const dashboard_settings_getDefaultEmployeeCount = "dashboard/settings/getDefaultEmployeeCount";
  static const dashboard_settings_saveDefaultEmployeeCount = "dashboard/settings/saveDefaultEmployeeCount";
  static const dashboard_settings_getShiftSectionEmployeeCount = "dashboard/settings/getShiftSectionEmployeeCount";
  static const dashboard_settings_saveShiftSectionEmployeeCount = "dashboard/settings/saveShiftSectionEmployeeCount";
  static const dashboard_settings_getDefaultShifts = "dashboard/settings/getDefaultShifts";
  static const dashboard_settings_saveDefaultShifts = "dashboard/settings/saveDefaultShifts";
  static const dashboard_settings_getShiftsByDate = "dashboard/settings/getShiftsByDate";
  static const dashboard_settings_saveShifts = "dashboard/settings/saveShifts";
  static const dashboard_getShift = "dashboard/getShift";
  static const dashboard_saveShifts = "dashboard/saveShifts";
  static const dashboard_x = "dashboard/x";
  static const data_getData = "data/getData";
  static const tabs_rename = "tabs/rename";
  static const tabs_logout = "tabs/logout";
  static const tabs_check = "tabs/check";
  static const tabs_tabList = "tabs/tabList";
  static const tabs_logList = "tabs/logList";
  static const tickets_upload = "tickets/upload";
  static const tickets_qc_getTicketQcList = "tickets/qc/getTicketQcList";
  static const tickets_qc_getList = "tickets/qc/getList";
  static const tickets_qc_qcImageList = "tickets/qc/qcImageList";
  static const tickets_qc_qcImageView = "tickets/qc/qcImageView";
  static const tickets_qc_qcImage = "tickets/qc/qcImage";
  static const tickets_qc_saveStatus = "tickets/qc/saveStatus";
  static const tickets_qc_uploadEdits = "tickets/qc/uploadEdits";
  static const tickets_standard_uploadEdits = "tickets/standard/uploadEdits";
  static const tickets_standard_getPdf = "tickets/standard/getPdf";
  static const tickets_standard_getPdf_d = "tickets/standard/getPdf/d";
  static const tickets_standard_getInfo = "tickets/standard/getInfo";
  static const tickets_standard_getList = "tickets/standard/getList";
  static const tickets_standard_getListByUptime = "tickets/standard/getListByUptime";
  static const tickets_standard_checkForDuplicate = "tickets/standard/checkForDuplicate";
  static const tickets_standard_upload = "tickets/standard/upload";
  static const tickets_standard_delete = "tickets/standard/delete";
  static const tickets_standard_changeFactory = "tickets/standard/changeFactory";
  static const tickets_flags_getList = "tickets/flags/getList";
  static const tickets_flags_setFlag = "tickets/flags/setFlag";
  static const tickets_flags_removeFlag = "tickets/flags/removeFlag";
  static const tickets_completed_getList = "tickets/completed/getList";
  static const tickets_completed_delete = "tickets/completed/delete";
  static const tickets_finish = "tickets/finish";
  static const tickets_finish_getMaxMinOpNo = "tickets/finish/getMaxMinOpNo";
  static const tickets_finish_getProgress = "tickets/finish/getProgress";
  static const tickets_finish_erpFinish = "tickets/finish/erpFinish";
  static const tickets_finish_pendingToFinishList = "tickets/finish/pendingToFinishList";
  static const tickets_print = "tickets/print";
  static const tickets_print_getList = "tickets/print/getList";
  static const tickets_print_getHistoryList = "tickets/print/getHistoryList";
  static const tickets_downloadTicket = "tickets/downloadTicket";
  static const tickets_uploadEdits = "tickets/uploadEdits";
  static const tickets_getTicketFile = "tickets/getTicketFile";
  static const tickets_comments_list = "tickets/comments/list";
  static const tickets_comments_save = "tickets/comments/save";
  static const tickets_getTickets = "tickets/getTickets";
  static const tickets_getProductionPoolTickets = "tickets/getProductionPoolTickets";
  static const tickets_search = "tickets/search";
  static const tickets_info_getTicketInfo = "tickets/info/getTicketInfo";
  static const tickets_updateFiles = "tickets/updateFiles";
  static const tickets_delete = "tickets/delete";
  static const tickets_deletePDF = "tickets/deletePDF";
  static const tickets_getDeletedTickets = "tickets/getDeletedTickets";
  static const tickets_rename = "tickets/rename";
  static const tickets_start = "tickets/start";
  static const tickets_getTicketProgress = "tickets/getTicketProgress";
  static const tickets_addTicket = "tickets/addTicket";
  static const sheet_upload = "sheet/upload";
  static const sheet_getSheetData = "sheet/getSheetData";
  static const users_getOTP = "users/getOTP";
  static const users_getUsers = "users/getUsers";
  static const users_saveRfCredentials = "users/saveRfCredentials";
  static const users_getRfCredentials = "users/getRfCredentials";
  static const users_getUser = "users/getUser";
  static const users_userImages_size_image = "users/userImages/size/image";
  static const users_setNfcCard = "users/setNfcCard";
  static const users_removeNfcCard = "users/removeNfcCard";
  static const users_deactivate = "users/deactivate";
  static const users_unlock = "users/unlock";
  static const users_saveImage = "users/saveImage";
  static const users_checkDuplicate = "users/checkDuplicate";
  static const users_saveUser = "users/saveUser";
  static const user_recoverPassword_sendOTP = "user/recoverPassword/sendOTP";
  static const user_recoverPassword_getUserByNic = "user/recoverPassword/getUserByNic";
  static const user_recoverPassword_validateOtp = "user/recoverPassword/validateOtp";
  static const user_recoverPassword_savePassword = "user/recoverPassword/savePassword";
  static const user_recoverPassword_sendOTPToAdmin = "user/recoverPassword/sendOTPToAdmin";
  static const user_login = "user/login";
  static const user_getUserData = "user/getUserData";
  static const user_setUserSection = "user/setUserSection";
  static const user_loginWithCookie = "user/loginWithCookie";
  static const user_loginWithCred = "user/loginWithCred";
  static const sections_getList = "sections/getList";
  static const materialManagement_cpr_sendCpr = "materialManagement/cpr/sendCpr";
  static const materialManagement_cpr_delete = "materialManagement/cpr/delete";
  static const materialManagement_cpr_search = "materialManagement/cpr/search";
  static const materialManagement_cpr_getCprsByTicketId = "materialManagement/cpr/getCprsByTicketId";
  static const materialManagement_cpr_checkItem = "materialManagement/cpr/checkItem";
  static const materialManagement_cpr_getCpr = "materialManagement/cpr/getCpr";
  static const materialManagement_cpr_getSails = "materialManagement/cpr/getSails";
  static const materialManagement_cpr_checkSailIsStanded = "materialManagement/cpr/checkSailIsStanded";
  static const materialManagement_cpr_getMaterilas = "materialManagement/cpr/getMaterilas";
  static const materialManagement_cpr_getAllMaterials = "materialManagement/cpr/getAllMaterials";
  static const materialManagement_cpr_saveCpr = "materialManagement/cpr/saveCpr";
  static const materialManagement_cpr_getExcel = "materialManagement/cpr/getExcel";
  static const materialManagement_kit_search = "materialManagement/kit/search";
  static const materialManagement_kit_getKit = "materialManagement/kit/getKit";
  static const materialManagement_kit_saveKitMaterials = "materialManagement/kit/saveKitMaterials";
  static const materialManagement_kit_checkItem = "materialManagement/kit/checkItem";
  static const materialManagement_kit_readyKit = "materialManagement/kit/readyKit";
  static const materialManagement_kit_order = "materialManagement/kit/order";
  static const materialManagement_kit_updateClient = "materialManagement/kit/updateClient";
  static const materialManagement_kit_sendKits = "materialManagement/kit/sendKits";
  static const materialManagement_kit_sendKit = "materialManagement/kit/sendKit";
  static const materialManagement_kit_getExcel = "materialManagement/kit/getExcel";
  static const materialManagement_deleteMaterial = "materialManagement/deleteMaterial";
  static const materialManagement_saveCprComment = "materialManagement/saveCprComment";
  static const materialManagement_getCprComments = "materialManagement/getCprComments";
  static const materialManagement_order = "materialManagement/order";
  static const materialManagement_orderKitByTicketId = "materialManagement/orderKitByTicketId";
  static const materialManagement_getOrderStatus = "materialManagement/getOrderStatus";
  static const permissions_permissionsList = "permissions/permissionsList";
  static const permissions_profilesList = "permissions/profilesList";
  static const permissions_userPermissions = "permissions/userPermissions";
  static const permissions_userPermissionsList = "permissions/userPermissionsList";
  static const permissions_saveUserPermissions = "permissions/saveUserPermissions";
  static const FileUpload_upload = "FileUpload/upload";
  static const tab_rename = "tab/rename";
  static const tab_logout = "tab/logout";
  static const tab_check = "tab/check";
  static const tab_tabList = "tab/tabList";
  static const tab_logList = "tab/logList";
  static const test = "test";
  static const downloadTicket = "downloadTicket";
  static const compress = "compress";
  static const _qc_images_ticketId_image = "/qc/images/ticketId/image";
  static const _images_profilePictures_size_image = "/images/profilePictures/size/image";
}
