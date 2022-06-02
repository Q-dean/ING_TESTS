/* Имеется декларация типа:

CREATE OR REPLACE TYPE TNUM as table of number;

Необходимо написать реализацию функции, возвращающая в качестве результата заполненный массив имеющий тип TNUM с значениями от 1..1000
*/

/*Комментарий: инициализируем коллекцию размером 1000 элементов и заполняем ее числами от 1 до 1000. 
               Так как заранее знаем размер коллекции можем использовать bulk collect, чтобы не прибегать к использованию цикла
*/


create or replace function f_fill_arr return tnum 
is
  t_arr tnum := tnum(1000);
begin
   
   select level
     bulk collect into t_arr
     from dual
  connect by level <= 1000;

  return t_arr; 
end;