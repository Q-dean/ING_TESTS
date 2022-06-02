/*
Имеется база данных по клиентам, имеющая структуру:
Клиенты 
ID	    number	
NAME	Varchar2	Наименование
		

Контакты
ID	        number	
CLIENT_ID	number	    FK CLIENT
C_TYPE	    number	    Тип контакта 1-телефон 2-email
C_INFO	    varchar2	Контакт – телефон либо адрес email
CREATED	    date	    Дата внесения в базу
ACTIVE	    Char(1)	    Y/N активный или архив

Адреса
ID	        number	
CLIENT_ID	number	    FK CLIENT
A_TYPE	    number	    Тип адреса 1-домашний 2-регистрации 3- фактический
CITY	    varchar2	Город
STREET	    varchar2	Улица
HOUSE	    varchar2	Дом
FLAT	    varchar2	Квартира
CREATED	    date	    Дата внесения в базу
ACTIVE	    Char(1)	    Y/N активный или архив

Отделу маркетинга требуется сводная выгрузка по клиентам, с гранулярностью до клиента, при этом для каждого клиента в выборке должны быть «лучшие»  адрес, телефон и адрес электронной почты. То есть, в результирующей выборке по каждому клиенту есть только одна строка. При этом:
1)	Лучший адрес отбирается по приоритету фактический > регистрации > домашний, при наличии нескольких адресов одного приоритета выбирается наиболее  полный (заполнено больше из перечня атрибутов city-street-house-flat, при равенстве по заполненности выбирается последний по дате внесения в базу.
2)	Лучший телефон это последний по дате внесения в базу
3)	Лучший email это первый по дате внесения в базу
4)	Данные по контактам и адресам – не архивные
*/

/*
Комментарий: 1) подготавливаем данные в cte:
                   phones - отбираем активные номера телефонов, нумеруем для каждого клиента в порядке убывания даты создания
				   emails - отбираем активные адреса э/п, нумеруем для каждого клиента в порядке убывания даты создания
				   addrs - отбираем активные адреса, нумеруем для каждого клиента согласно некоторому рассчитаному весу адреса и убыванию даты создания
				           вес адреса показывает насколько этот адрес "лучше" других 
                           вес рассчитывается по следующему правилу: тип адреса (имеет значения 1, 2, 3) умножается на 10, так как имеет большее значение по сравнению с заполненностью атрибутов
                           затем каждый заполненный атрибут (город, улица, дом, квартира) добавляет к весу по единице, для дифференциации адресов одного типа 					   
			 2)	собираем итоговую выборку:
                    к информации о клиентах добавляем информацию о номере, адресе э/п и адресе жительства из подготовленных данных
                    используем left join, так как возможно есть клиенты с незаполненной информацией о сущностях
                    оставляем только те записи, которые имеют нумерацию равную 1, так как согласно условиям эта запись будет "лучшей"					
*/


with phones as (
  select con.client_id,
         con.c_info,
         row_number() over(partition by con.client_id 
                           order by con.created desc) as rn
    from contacts con
   where con.c_type = 1
     and con.active = 'Y'
),

emails as (
  select con.client_id,
         con.c_info,
         row_number() over(partition by con.client_id 
                           order by con.created desc) as rn
    from contacts con
   where con.c_type = 2
     and con.active = 'Y'
),

addrs as (
  select ad.client_id,
         decode(ad.a_type, 1, 'Домашний',
                           2, 'Регистрации',
                           3, 'Фактический',
                           'Не определено') as type,
         ad.city || ',' || ad.street || ',' || ad.house || ',' || ad.flat as full_address,
         row_number() over(partition by ad.client_id 
                           order by ad.a_type * 10 + (nvl2(ad.city, 1, 0) + nvl2(ad.street, 1, 0) + nvl2(ad.house, 1, 0) + nvl2(ad.flat, 1, 0)) desc,
                                    ad.created desc) as rn
    from addresses ad
   where ad.active = 'Y'
)

select c.name         as "ФИО клиента",
       p.c_info       as "Контактный номер",
       e.c_info       as "Адрес электронной почты",
       a.type         as "Тип адреса",
       a.full_address as "Адрес" 
  from clients c left join phones p on c.id = p.client_id
                 left join emails e on c.id = e.client_id
                 left join addrs  a on c.id = a.client_id
 where nvl(p.rn, 1) = 1
   and nvl(e.rn, 1) = 1
   and nvl(a.rn, 1) = 1                

