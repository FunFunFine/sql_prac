/*
1. Построить процедуру(функцию), показывающую количество газа, которое остается в регионе.

2. Найти компанию, в которой работает самый старый сотрудник.

3. Найти регион, в котором работает больше всего сотрудников на одной вышке.

4. Построить функцию, которая вычисляет эффективность вышки,
где эффективность вышки есть отношение объема добычи к числу сотрудников на ней;
если сотрудников нет, то эффективность нулевая.

5. Построить курсор, который показывает информацию о вышках:
в каком регионе находится, какой компании принадлежит, сколько сотрудников работает.

6. Создать триггер, который запретит добавлять вышки в регион,
если в этом регионе уже добывается весь газ.
*/

-- 1

delimiter ##
create procedure GasAmount(
    in RegionId integer
)
begin
    select ExistingGasAmount, GasTowers.GasProductionRate
    from Regions
             join GasTowers on Regions.Id = GasTowers.RegionId
    where Regions.Id = RegionId;
end ##
delimiter ;

-- 2
select Employees.Age, Employees.Name, Companies.Name
from Employees
         join Companies on Employees.CompanyId = Companies.Id
order by Employees.Age desc
limit 1;

-- 3
create function TowerEmployeesCount(tid integer) returns integer
begin
    declare c integer;
    select count(Id) into c from Employees where TowerId = tid;
    return c;
end;

select Regions.Name, GT.Name, TowerEmployeesCount(GT.Id)
from Regions
         join GasTowers GT on Regions.Id = GT.RegionId
order by TowerEmployeesCount(GT.Id) desc;

-- 4
create function TowerEfficiency(tid int) returns double
begin
    declare result double;
    declare count integer;
    set count = TowerEmployeesCount(tid);
    select if(count = 0, 0, GasProductionRate / count) into result from GasTowers where Id = tid limit 1;
    return result;
end;

select Name, TowerEfficiency(Id) eff
from GasTowers
order by eff desc;

-- 5

-- 6
create trigger GasTowerInsertPrevention
    before insert
    on GasTowers
    for each row
begin
    declare extractedGasAmount integer;
    declare regionGasAmount integer;
    select ExistingGasAmount into regionGasAmount from Regions where RegionId = new.RegionId limit 1;
    select sum(GasTowers.GasProductionRate) into extractedGasAmount from GasTowers where new.RegionId = RegionId;
    if regionGasAmount - extractedGasAmount < new.GasProductionRate then
        signal sqlstate '45000';
    end if;
end;


