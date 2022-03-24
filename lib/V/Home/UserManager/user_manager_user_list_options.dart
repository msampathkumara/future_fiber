part of 'user_manager_user_list.dart';

Future<void> showUserOptions(NsUser nsUser, BuildContext context1, context, nfcIsAvailable) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), color: Colors.white),
        height: 500,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: UserImage(nsUser: nsUser, radius: 24),
                title: Text(nsUser.name),
                subtitle: Text("#" + nsUser.uname),
              ),
              Divider(),
              if (nfcIsAvailable)
                ListTile(
                  title: Text(nsUser.userHasNfc() ? "Remove ID Card" : "Add ID Card"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.nfc_outlined),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (nsUser.userHasNfc()) {
                      // todo add remove id card code

                      showRemoveCardAlertDialog(context);
                    } else {
                      showAddNfcDialog(nsUser, context);
                    }
                  },
                ),
              if (AppUser.havePermissionFor(Permissions.UPDATE_USER))
                ListTile(
                  title: Text("Edit"),
                  subtitle: Text("Update user details"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.edit),
                  ),
                  onTap: () async {
                    UpdateUserDetails.show(context, nsUser);
                  },
                ),
              if (AppUser.havePermissionFor(Permissions.SET_USER_PERMISSIONS))
                ListTile(
                  title: Text("Permissions"),
                  subtitle: Text("Update,Add or Remove Permissions"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.gpp_good_outlined),
                  ),
                  onTap: () async {
                    UserPermissions.show(context, nsUser);
                  },
                ),
              if (AppUser.havePermissionFor(Permissions.DEACTIVATE_USERS))
                ListTile(
                  title: Text(nsUser.isDisabled ? "Activate User" : "Deactivate User"),
                  subtitle: Text(nsUser.isDisabled ? "Activate all activities on system for this user" : "Deactivate all activities on system for this user"),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.person_off_rounded),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    Loading loading = Loading();
                    loading.show(context1);

                    OnlineDB.apiPost('users/deactivate', {"userId": nsUser.id, "deactivate": (!nsUser.isDisabled)}).then((value) {
                      print('cccccccccccccccccccccccccc');
                      HiveBox.getDataFromServer();
                      loading.close(context1);
                    });
                  },
                ),
              Spacer(),
            ],
          ),
        ),
      );
    },
  );
}

showRemoveCardAlertDialog(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: Text("Continue"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Remove ID card ?"),
    content: Text("this will remove id card from user "),
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
