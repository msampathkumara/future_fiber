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
                          leading: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.nfc_outlined)),
                          onTap: () async {
                            Navigator.of(context).pop();
                            if (nsUser.userHasNfc()) {
                              // todo add remove id card code

                              showRemoveCardAlertDialog(context, onRemoveNfcCard);
                            } else {
                              showAddNfcDialog(nsUser, context);
                            }
                          }),
                    if ((kIsWeb))
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
                    ListTile(
                      title: Text(nsUser.isDeactivated ? "Activate User" : "Deactivate User"),
                      subtitle: Text(nsUser.isDeactivated ? "Activate all activities on system for this user" : "Deactivate all activities on system for this user"),
                      leading: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.person_off_rounded),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        deactivateUser(nsUser);
                      },
                    ),
                    if (nsUser.isLocked)
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
  ShowMessage(nsUser.isDeactivated ? "Activating" : "Deactivating..");
  Api.post(EndPoints.users_deactivate, {"userId": nsUser.id, "deactivate": (!nsUser.isDeactivated)}).then((value) {
    print('cccccccccccccccccccccccccc');
    ShowMessage(nsUser.isDeactivated ? "User Account Activating" : "User Account Deactivated..");
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

showRemoveCardAlertDialog(context, onRemoveNfcCard) {
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Remove ID card ?"),
        content: const Text("this will remove id card from user "),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
              child: const Text("Continue"),
              onPressed: () {
                Navigator.of(context).pop();
                onRemoveNfcCard();
              }),
        ],
      );
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
