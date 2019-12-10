create table Companies
(
    Id             integer     not null auto_increment,
    Name           varchar(50) not null unique,
    FoundationYear date        not null,
    primary key (Id)

);

create table Regions
(
    Id                integer      not null auto_increment,
    ExistingGasAmount integer      not null,
    Name              varchar(100) not null,
    primary key (Id)
);
create table GasTowers
(
    RegionId          integer     not null,
    CompanyId         integer     not null,
    Id                integer auto_increment,
    GasProductionRate integer     not null default 50,
    BuildingDate      date        not null,
    Name              varchar(20) not null default 'Nameless',
    primary key (Id),
    foreign key (CompanyId) references Companies (Id),
    foreign key (RegionId) references Regions (Id)
);

create table Employees
(
    Id        integer auto_increment not null,
    Name      varchar(100)           not null,
    CompanyId integer                not null,
    TowerId   integer                not null,
    Age       tinyint unsigned default 30,
    primary key (Id),
    foreign key (CompanyId) references Companies (Id),
    foreign key (TowerId) references GasTowers (Id)
);