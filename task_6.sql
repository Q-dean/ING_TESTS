/*Имеется таблица dept со следующей структурой:

Name   Type         Nullable Default Comments 
------ ------------ -------- ------- -------- 
DEPTNO NUMBER                                 
DNAME  VARCHAR2(14) Y                         
LOC    VARCHAR2(13) Y                         

Необходимо реализовать функцию PL/SQL которая будет возвращать выборку из таблицы dept заданную минимальным и максимальным значением поля DEPTNO. Реализуемая функция должна использовать метод pipelined.
*/

/*Комментарий: для удобства объединяем все в пакет.
               Заводим тип record, затем nested table коллекцию из этих записей и конвейерную функцию, возвращающую данную коллекцию
               В функции отбираем данные из таблицы согласно условию и реализуем конвейер
               Проверим работу функции, передавая различные входные параметры
*/


create or replace package pkg_dept
is
  type r_dept is record(
    deptno dept.deptno%type,
    dname  dept.dname%type,
    loc    dept.loc%type
  );

  type t_dept is table of r_dept;

  function f_get_dept(p_min_deptno number, p_max_deptno number) return t_dept pipelined; 
end;

create or replace package body pkg_dept
is
  function f_get_dept(p_min_deptno number, p_max_deptno number) return t_dept pipelined 
  is
  begin
    for r in (select d.deptno,
                     d.dname,
                     d.loc
                from dept d
               where deptno >= p_min_deptno
                 and deptno <= p_max_deptno)
    loop
      pipe row(r);  
    end loop;         
  end f_get_dept;
end;

-- проверка функции
select * from table(pkg_dept.f_get_dept(10, 50)); 