class User {

    User( );

    factory User.fromJson(Map<String, dynamic> json) {
        return User(
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        return data;
    }
}