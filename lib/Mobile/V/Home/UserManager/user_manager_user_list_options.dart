part of 'user_manager_user_list.dart';

Future<void> showUserOptions(NsUser nsUser, BuildContext context1, context, nfcIsAvailable, {required Function onRemoveNfcCard}) async {
  await showModalBottomSheet<void>(
    constraints: kIsWeb ? const BoxConstraints(maxWidth: 600) : null,
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 600,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: UserImage(nsUser: nsUser, radius: 24),
                title: Text(nsUser.name),
                subtitle: Text("#${nsUser.uname}"),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    if (nfcIsAvailable)
                      ListTile(
                        title: Text(nsUser.userHasNfc() ? "Remove ID Card" : "Add ID Card"),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.nfc_outlined),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          if (nsUser.userHasNfc()) {
                            // todo add remove id card code

                            showRemoveCardAlertDialog(context1, onRemoveNfcCard);
                          } else {
                            showAddNfcDialog(nsUser, context1);
                          }
                        },
                      ),
                    if ((kIsWeb) && AppUser.havePermissionFor(NsPermissions.USERS_UPDATE_USER))
                      ListTile(
                        title: const Text("Edit"),
                        subtitle: const Text("Update user details"),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.edit),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          UpdateUserDetails(nsUser).show(context);
                        },
                      ),
                    if (AppUser.havePermissionFor(NsPermissions.USERS_EDIT_PERMISSIONS))
                      ListTile(
                        title: const Text("Permissions"),
                        subtitle: const Text("Update,Add or Remove Permissions"),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.gpp_good_outlined),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          UserPermissions(nsUser).show(context);
                        },
                      ),
                    if (AppUser.havePermissionFor(NsPermissions.USERS_DEACTIVATE_USERS))
                      ListTile(
                        title: Text(nsUser.isDisabled ? "Activate User" : "Deactivate User"),
                        subtitle: Text(nsUser.isDisabled ? "Activate all activities on system for this user" : "Deactivate all activities on system for this user"),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.person_off_rounded),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          deactivateUser(nsUser);
                        },
                      ),
                    if (nsUser.isLocked && AppUser.havePermissionFor(NsPermissions.USER_UNLOCK_USER))
                      ListTile(
                        title: const Text("Unlock User"),
                        subtitle: const Text(" "),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.lock_open_rounded),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          ShowMessage("Unlocking user..");

                          Api.post(EndPoints.users_unlock, {"userId": nsUser.id}).then((value) {
                            HiveBox.getDataFromServer();
                            ShowMessage("User Unlocked");
                          });
                        },
                      ),
                    if (AppUser.havePermissionFor(NsPermissions.USERS_RESET_PASSWORD))
                      ListTile(
                        title: const Text("Reset Password"),
                        subtitle: const Text("Generate OTP to reset Password"),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.password_rounded),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          GenerateOTP(nsUser).show(context);
                        },
                      ),
                    if (AppUser.havePermissionFor(NsPermissions.USERS_RESET_PASSWORD))
                      ListTile(
                        title: const Text("Generate Password"),
                        subtitle: const Text("Generate   Password"),
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.password_rounded),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          GeneratePassword(nsUser).show(context);
                        },
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

void deactivateUser(nsUser) {
  ShowMessage(nsUser.isDisabled ? "Activating" : "Deactivating..");
  Api.post(EndPoints.users_deactivate, {"userId": nsUser.id, "deactivate": (!nsUser.isDisabled)}).then((value) {
    print('cccccccccccccccccccccccccc');
    ShowMessage(nsUser.isDisabled ? "User Account Activating" : "User Account Deactivated..");
    HiveBox.getDataFromServer();
  }).catchError((err) {
    ShowMessage("Something went wrong.. please retry",
        duration: const Duration(seconds: 15),
        messageType: MessageTypes.error,
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              deactivateUser(nsUser);
            },
            textColor: Colors.white));
  });
}

showRemoveCardAlertDialog(BuildContext context, onRemoveNfcCard) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop();
        onRemoveNfcCard();
      });

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Remove ID card ?"),
    content: const Text("this will remove id card from user "),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void showAddNfcDialog(nsUser, context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNfcCard(nsUser);
      });
}