-- 1. Построить процедуру(функцию), показывающую количество газа, которое остается в регионе.

delimiter ##
create procedure GasAmount(
    in rId integer
)
begin
    declare extracted integer;
    select sum(GasProductionRate) into extracted from GasTowers where RegionId = rId;
    select ExistingGasAmount - extracted
    from Regions
    where Regions.Id = rId;
end ##
delimiter ;

-- check
call GasAmount(92);

-- 2. Найти компанию, в которой работает самый старый сотрудник.

select Employees.Age, Employees.Name, Companies.Name
from Employees
         join Companies on Employees.CompanyId = Companies.Id
order by Employees.Age desc
limit 1;

/* 3. Найти регион, в котором работает больше всего сотрудников на одной вышке.*/
create function TowerEmployeesCount(tid integer) returns integer
begin
    declare c integer;
    select count(Id) into c from Employees where TowerId = tid;
    return c;
end;

select Regions.Name, GT.Name, TowerEmployeesCount(GT.Id) emplCount
from Regions
         join GasTowers GT on Regions.Id = GT.RegionId
order by emplCount desc;

/* 4. Построить функцию, которая вычисляет эффективность вышки,
где эффективность вышки есть отношение объема добычи к числу сотрудников на ней;
если сотрудников нет, то эффективность нулевая. */
create function TowerEfficiency(tid int) returns double
begin
    declare result double;
    declare count integer;
    set count = TowerEmployeesCount(tid);
    select if(count = 0, 0, GasProductionRate / count) into result from GasTowers where Id = tid limit 1;
    return result;
end;

-- check
select Name, TowerEfficiency(Id) eff
from GasTowers
order by eff desc;

/* 5. Построить курсор, который показывает информацию о вышках:
в каком регионе находится, какой компании принадлежит, сколько сотрудников работает.*/
drop procedure ShowTowers;
delimiter ##
create procedure ShowTowers(rowsAmount integer)
begin
    declare tid integer;
    declare tn varchar(20);
    declare rn varchar(100);
    declare cn varchar(50);
    declare ea integer;
    declare counter integer default 0;
-- create cursor
    declare towers cursor for
        select GasTowers.Id        TowerId,
               GasTowers.Name      TowerName,
               Regions.Name        RegionName,
               Companies.Name      CompanyName,
               count(Employees.Id) EmployeesCount
        from GasTowers
                 join Companies on GasTowers.CompanyId = Companies.Id
                 join Employees on GasTowers.Id = Employees.TowerId
                 join Regions on GasTowers.RegionId = Regions.Id
        group by GasTowers.Id, GasTowers.Name, Regions.Name, Companies.Name;
-- use it in some way
    create table if not exists towersInfo
    (
        TowerId         integer,
        TowerName       varchar(20),
        RegionName      varchar(100),
        CompanyName     varchar(50),
        EmployeesAmount integer
    );
    open towers;
    while counter < rowsAmount
        do
            fetch towers into tid,tn,rn,cn,ea;
            insert into towersInfo (TowerId, TowerName, RegionName, CompanyName, EmployeesAmount)
            values (tid, tn, rn, cn, ea);
            set counter = counter + 1;
        end while;

    close towers;
end ##
delimiter ;

-- check
call ShowTowers(5);
/* 6. Создать триггер, который запретит добавлять вышки в регион,
если в этом регионе уже добывается весь газ. */

create trigger GasTowerInsertPrevention
    before insert
    on GasTowers
    for each row
begin
    declare extractedGasAmount integer;
    declare regionGasAmount integer;
    select ExistingGasAmount into regionGasAmount from Regions where Regions.Id = new.RegionId limit 1;
    select sum(GasTowers.GasProductionRate) into extractedGasAmount from GasTowers where new.RegionId = RegionId;
    if regionGasAmount - extractedGasAmount < new.GasProductionRate then
        signal sqlstate '45000' SET MESSAGE_TEXT = 'There is enough gas extracted in this region';
    end if;
end;

-- check
select *
from Regions
where Id = 92;

insert into GasTowers (RegionId, CompanyId, BuildingDate, GasProductionRate)
VALUES (92, 1, '1996-03-08', 2);

select *
from GasTowers
where BuildingDate = '1996-03-08';


