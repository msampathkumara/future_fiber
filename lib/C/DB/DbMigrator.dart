class DbMigrator {
  static final Map<int, List<String>> migrations = {
    1: [
      "create table tickets ( id int primary key, mo varchar(100)  null, oe varchar(100) null, finished tinyint default 0 null, dir tinyint  null, uptime datetime default 0 null, file tinyint default 0 null, sheet tinyint default 0 null, production varchar(10) null, isRed tinyint default 0 null, isRush tinyint default 0 null, inPrint tinyint default 0 null, isError tinyint default 0 null, `delete` tinyint default 0 null, reNamed tinyint default 0 null, progress int default 0 null,   unique (mo) );",
      "ALTER TABLE tickets ADD canOpen tinyint default 1;",
      "ALTER TABLE tickets ADD isGr tinyint default 0;",
      "ALTER TABLE tickets ADD isSk tinyint default 0;",
      "ALTER TABLE tickets ADD isHold tinyint default 0;",
      "create table files (ticket int ,ver int , unique (ticket)) ",
      "alter table tickets add openSections TEXT default '' null;",
      "CREATE INDEX ticketsIndex ON tickets;",
      "alter table tickets add completed tinyint default 0 null;",
      "alter table tickets add nowAt int default 0;",
      "alter table tickets add fileVersion int default 0 null;"
    ],
    2: [
      "create table flags ( id int primary key, ticket int null, type varchar(10) null, comment longtext null, dnt datetime   null, user int null ,UNIQUE(ticket, type) ON CONFLICT REPLACE )",
      "create table ticketProgressDetails( id int, operation text null, finishedOn text default 0 null, finishedBy int null, finishedAt int null, status int default 0 null, operationNo int null, ticketId int not null, nextOperationNo int default 0 null, doAt int default 0 null, constraint ticketProgressDetails_uindex unique (operation, operationNo, nextOperationNo, ticketId));",
      "ALTER TABLE ticketProgressDetails ADD upon text default 0;"
    ],
    3: ["alter table tickets add crossPro int default 0 ;"],
    5: ["alter table tickets add crossProList Text default  '[]'  ;"],
    6: ["alter table tickets add oldProd Text default  null  ;"],
    7: ["alter table tickets add atSection Text default  ''  ;"],
  };
}
