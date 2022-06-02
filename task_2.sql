/* Имеется таблица без первичного ключа. Известно, что в таблице имеется задвоение данных. Необходимо удалить дубликаты из таблицы.
create table t (a number, b number);

Пример данных:
a	b
1	1
2	2
2	2
3	3
3	3
3	3
Требуемый результат:
a	b
1	1
2	2
3	3
*/

/* Комментарий: у дубликатов будет разный rowid - используя max или min отбираем единственный экземпляр для каждой группы дубликатов*/


with max_rowid as
(select max(rowid) as rid
   from t
  group by a, b)

select t.a, 
       t.b
  from t join max_rowid mr on t.rowid = mr.rid;