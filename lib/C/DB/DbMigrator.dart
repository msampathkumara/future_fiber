class DbMigrator {
  static final Map<int, List<String>> migrations = {
    1: [
      "create table tickets ( id int primary key, mo varchar(100)  null, oe varchar(100) null, finished tinyint default 0 null, dir tinyint  null, uptime datetime default 0 null, file tinyint default 0 null, sheet tinyint default 0 null, production varchar(10) null, isRed tinyint default 0 null, isRush tinyint default 0 null, inPrint tinyint default 0 null, isError tinyint default 0 null, `delete` tinyint default 0 null, reNamed tinyint default 0 null, progress double default 0 null,   unique (mo) );",
      "ALTER TABLE tickets ADD canOpen tinyint default 1;",
      "ALTER TABLE tickets ADD isGr tinyint default 0;",
      "ALTER TABLE tickets ADD isSk tinyint default 0;",
      "ALTER TABLE tickets ADD isHold tinyint default 0;",
      "create table files (ticket int ,ver int , unique (ticket)) "
    ],
    2: ["alter table tickets add fileVersion int default 0 null;"]
  };
}
