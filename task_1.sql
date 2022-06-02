/*Вывести 1000 случайных чисел от 1 до 1000, 
  таких что не повторяются в этой последовательности, 
  больше чем 3 раза.*/
  
/*Решение в SQL:
  - подготавливаем набор возможных данных (числа от 1 до 1000 дублируем 3 раза)  
  - забираем из подготовленного набора 1000 случайных чисел 
*/

with numbers as (
   select ceil(level / 3) as lvl
     from dual
  connect by level <= 3 * 1000
)

select mix.lvl
  from (select lvl
          from numbers
         order by dbms_random.value) mix
 where rownum <= 1000;        
