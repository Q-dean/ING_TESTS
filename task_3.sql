/*Имеется 
xmltype('
<root>
  <row>
    <col>v11</col>
    <col>v12</col>
    <col>v13</col>
    <col>v14</col>
  </row>
  <row>
    <col>v21</col>
    <col>v22</col>
    <col>v23</col>
    <col>v24</col>
  </row>
</root>')

Необходимо:

a)Получить выборку

C1   C2   C3   C4
---- ---- ---- ----
v11  v12  v13  v14
v21  v22  v23  v24

Условия: количество узлов row может варьироваться, col всегда статично = 4 шт в пределах row*/

with data as (
    select xmltype('<root>
                      <row>
                        <col>v11</col>
                        <col>v12</col>
                        <col>v13</col>
                        <col>v14</col>
                      </row>
                      <row>
                        <col>v21</col>
                        <col>v22</col>
                        <col>v23</col>
                        <col>v24</col>
                      </row>
                    </root>') as xml_data
    from dual                
)

select xml_tbl.c1,
       xml_tbl.c2,
       xml_tbl.c3,
       xml_tbl.c4
  from data,
       xmltable('/root/row' 
                passing data.xml_data
                columns 
                  c1 varchar2(100) path 'col[1]',
                  c2 varchar2(100) path 'col[2]',
                  c3 varchar2(100) path 'col[3]',
                  c4 varchar2(100) path 'col[4]') xml_tbl;
				  
				  
				  
				  
				  
/*b) Получить в виде результата колонку с типом xmltype SQL запроса со следующей структурой:

<root>
   <data row="1" col="1">v11</data>
   <data row="1" col="2">v12</data>
   <data row="1" col="3">v13</data>
   <data row="1" col="4">v14</data>
   <data row="2" col="1">v21</data>
   <data row="2" col="2">v22</data>
   <data row="2" col="3">v23</data>
   <data row="2" col="4">v24</data>
</root>


Реализовать данный запрос не используя XSLT трансформацию.
Условия: количество узлов row и col может варьироваться (прим. это более сложный пример, можно вернуть условие что количество col всегда статично = 4 шт в пределах row)
*/ 

with data as (
    select 1 as row_id, 1 as col_id, 'v11' as val
    from dual
    union all
    select 1 as row_id, 2 as col_id, 'v12' as val
    from dual
    union all
    select 1 as row_id, 3 as col_id, 'v13' as val
    from dual
    union all
    select 1 as row_id, 4 as col_id, 'v14' as val
    from dual
    union all
    select 2 as row_id, 1 as col_id, 'v21' as val
    from dual
    union all
    select 2 as row_id, 2 as col_id, 'v22' as val
    from dual
    union all
    select 2 as row_id, 3 as col_id, 'v23' as val
    from dual
    union all
    select 2 as row_id, 4 as col_id, 'v24' as val
    from dual
)

SELECT XMLElement("root", 
                   XMLAgg(XMLElement("data", 
                              XMLAttributes(
                                  d.row_id as "row",
                                  d.col_id AS "col"),
                              d.val)
                          order by d.row_id, d.col_id)) as val
FROM data d;

/*
c) Получить в виде результата колонку с типом xmltype SQL запроса со следующей структурой:

<root>
   <data row="1" col="1">v11</data>
   <data row="1" col="2">v12</data>
   <data row="1" col="3">v13</data>
   <data row="1" col="4">v14</data>
   <data row="2" col="1">v21</data>
   <data row="2" col="2">v22</data>
   <data row="2" col="3">v23</data>
   <data row="2" col="4">v24</data>
</root>


Реализовать данный запрос используя XSLT трансформацию.
Условия: количество узлов row и col может варьироваться
*/

--К сожалению, не знаком с XSLT трансформацией.