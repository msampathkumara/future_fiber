class DbMigrator {
  static final Map<int, List<String>> migrations = {
    1: [
      "create table tickets ( id int primary key, mo varchar(100) null, oe varchar(100) null, finished tinyint default 0 null, dir tinyint null, uptime datetime default 0 null, file tinyint default 0 null, sheet tinyint default 0 null, production varchar(10) null, isRed tinyint default 0 null, isRush tinyint default 0 null, inPrint tinyint default 0 null, isError tinyint default 0 null, `delete` tinyint default 0 null, reNamed tinyint default 0 null, progress int default 0 null, unique (mo) );",
      "ALTER TABLE tickets ADD canOpen tinyint default 1;",
      "ALTER TABLE tickets ADD isGr tinyint default 0;",
      "ALTER TABLE tickets ADD isSk tinyint default 0;",
      "ALTER TABLE tickets ADD isHold tinyint default 0;",
      "create table files (ticket int ,ver int , unique (ticket)) ",
      "alter table tickets add openSections TEXT default '' null;",
      "CREATE INDEX ticketsIndex ON tickets",
      "alter table tickets add completed tinyint default 0 null;",
      "alter table tickets add nowAt int default 0;",
      "alter table tickets add fileVersion int default 0 null;"
    ],
    2: [
      "create table flags ( id int primary key, ticket int null, type varchar(10) null, comment longtext null, dnt datetime null, user int null ,UNIQUE(ticket, type) ON CONFLICT REPLACE )",
      "create table ticketProgressDetails( id int, operation text null, finishedOn text default 0 null, finishedBy int null, finishedAt int null, status int default 0 null, operationNo int null, ticketId int not null, nextOperationNo int default 0 null, doAt int default 0 null, constraint ticketProgressDetails_uindex unique (operation, operationNo, nextOperationNo, ticketId));",
      "ALTER TABLE ticketProgressDetails ADD upon text default 0;"
    ],
    3: ["alter table tickets add crossPro int default 0 ;"],
    5: ["alter table tickets add crossProList Text default '[]' ;"],
    6: ["alter table tickets add oldProd Text default null ;"],
    7: ["alter table tickets add atSection Text default '' ;"],
    8: ["alter table tickets add fileName Text default '' ;"],
    9: ["alter table tickets add custom Text default '' ;"],
    10: ["alter table tickets add ticketProgress Text default '' ;"],
    11: ["alter table flags add flaged int default 0 ;"],
    14: [
      "DROP TABLE IF EXISTS users",
      "DROP TABLE IF EXISTS userSections",
      "create table users ( id int primary key, uname varchar(255) not null, utype varchar(255) default 'user' not null, status varchar(255) default 'ok' not null, epf varchar(255) null, etype int null, loft int null, phone varchar(255) null, sectionId int default 0 not null, name varchar(255) null, img varchar(255) null, claimVersion int default 0 null, uptime varchar(20) default null, deleted int default 0 null, md5Id varchar(100) null, emailAddress longtext null, UNIQUE (id) ON CONFLICT REPLACE );",
      "create table userSections ( userId int, sectionId int, UNIQUE (userId,sectionId) ON CONFLICT REPLACE );"
    ],
    16: [
      "DROP TABLE IF EXISTS factorySections",
      "create table factorySections ( id int, sectionTitle varchar(50) null, factory varchar(30) null, loft int null,uptime varchar(20) null, UNIQUE (id) ON CONFLICT REPLACE );"
    ],
    20: [
      "alter table users add hasNfc int default 0 ;",
      "create table standardTickets ( id int, oe varchar(50) null, usedCount int default 0  , uptime INT default 0, production varchar(15) null, fileVersion INT default 0 null, UNIQUE (id) ON CONFLICT REPLACE )",
      "alter table files add type Text default  '' ;"
    ],
    21: [
      "alter table users add address text default '' ;",
    ],
    24: ["create table maxUpTimes ( collection varchar(20), uptime varchar(20), UNIQUE (collection) ON CONFLICT REPLACE );"],
    26: ["alter table tickets add isSort int default 0 ;"],
    27: ["alter table tickets add shipDate datetime default 0 ;"],
    28: ["alter table tickets add deliveryDate datetime default 0 ;"],
    29: ["alter table users add deactivate int default 0 ;"],
    30: ["alter table standardTickets add `delete` int default 0 ;"]
  };
}
