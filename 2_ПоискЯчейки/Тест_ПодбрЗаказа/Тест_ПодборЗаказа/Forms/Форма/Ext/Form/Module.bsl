﻿// BSLLS-off

&НаКлиенте
Процедура Подобрать(Команда)
	ПодобратьНаСервере(Склад, ИсходнаяЯчейка);
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПодобратьНаСервере(Склад, ИсходнаяЯчейка)
	
	//{{ Получение таблицы ячеек с индексами удаленности от исходной
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	СтруктураАдресаНулевойЯчейки = Новый Структура("Секция, Линия, Стеллаж, Ярус, Подход");
	ЗаполнитьЗначенияСвойств(СтруктураАдресаНулевойЯчейки, ИсходнаяЯчейка);

	ПолучитьТаблицуЯчеекСИндексамиУдаленности(Запрос, СтруктураАдресаНулевойЯчейки, Склад);	
	//}} 
	
	Запрос.УстановитьПараметр("Склад", Склад ); 
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	Склады.Ссылка КАК СсылкаСклад
	               |ПОМЕСТИТЬ ВтДопустимыеСклады
	               |ИЗ
	               |	Справочник.Склады КАК Склады
	               |ГДЕ
	               |	Склады.Ссылка = &Склад
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ИсторияСтатусовЗаказовСрезПоследних.ЗаказКлиента КАК ЗаказСсылка
	               |ПОМЕСТИТЬ ВтПодходящиеЗаказы
	               |ИЗ
	               |	РегистрСведений.ИсторияСтатусовЗаказов.СрезПоследних КАК ИсторияСтатусовЗаказовСрезПоследних
	               |ГДЕ
	               |	ИсторияСтатусовЗаказовСрезПоследних.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыЗаказаКлиента_Ванцзи.Подтвержден)
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	ЗаказСсылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВтПодходящиеЗаказы.ЗаказСсылка,
	               |	Док_ЗаказКлиента.ЭтоЗаказУмка
	               |ПОМЕСТИТЬ ВтДанныеЗаказов
	               |ИЗ
	               |	ВтПодходящиеЗаказы КАК ВтПодходящиеЗаказы
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК Док_ЗаказКлиента
	               |		ПО ВтПодходящиеЗаказы.ЗаказСсылка = Док_ЗаказКлиента.Ссылка
	               |ГДЕ
	               |	Док_ЗаказКлиента.Склад В
	               |			(ВЫБРАТЬ
	               |				ВтДопустимыеСклады.СсылкаСклад
	               |			ИЗ
	               |				ВтДопустимыеСклады)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВтПодходящиеЗаказы.ЗаказСсылка,
	               |	Док_ЗаказКлиента.ЭтоЗаказУмка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВтПодходящиеЗаказы.ЗаказСсылка КАК ЗаказСсылка,
	               |	ЗаказКлиентаЯчейки.Ячейка КАК Ячейка,
	               |	ЗаказКлиентаЯчейки.Номенклатура
	               |ПОМЕСТИТЬ ВтТоварыПоМестамХранения
	               |ИЗ
	               |	ВтПодходящиеЗаказы КАК ВтПодходящиеЗаказы
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Ячейки КАК ЗаказКлиентаЯчейки
	               |		ПО ВтПодходящиеЗаказы.ЗаказСсылка = ЗаказКлиентаЯчейки.Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ ПЕРВЫЕ 1
	               |	ВтДанныеЗаказов.ЗаказСсылка КАК ЗаказКлиента,
	               |	ТоварыПоМестамХранения.Ячейка КАК Ячейка,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности0,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности1,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности4,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности2,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности3
	               |ИЗ
	               |	ВтДанныеЗаказов КАК ВтДанныеЗаказов
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВтТоварыПоМестамХранения КАК ТоварыПоМестамХранения
	               |			ЛЕВОЕ СОЕДИНЕНИЕ ВтЯчекиСИндексомУдаленности КАК ВтЯчекиСИндексомУдаленности
	               |			ПО ТоварыПоМестамХранения.Ячейка = ВтЯчекиСИндексомУдаленности.ССЫЛКА
	               |		ПО ВтДанныеЗаказов.ЗаказСсылка = ТоварыПоМестамХранения.ЗаказСсылка
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности0,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности1,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности4,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности2,
	               |	ВтЯчекиСИндексомУдаленности.ИндексУдаленности3"; 

	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ""+Выборка.ЗаказКлиента+Символы.ПС+Выборка.Ячейка;
		Сообщение.Сообщить(); 	
	КонецЕсли;
		
КонецПроцедуры


&НаСервереБезКонтекста
Процедура ПолучитьТаблицуЯчеекСИндексамиУдаленности(Запрос, СтруктураАдресаНулевойЯчейки, Склад) Экспорт 
	
	// Индексы: 
	// 0 - Секция
	// 1 - Линия
	// 2 - Стеллаж
	// 3 - Ярус
	// 4 - Подход
	
	
	ВыполнитьЗапрос_ВсеЯчейкиСклада(Запрос, Склад);
	
	ПоместитьТаблицуЧастейАдреса(Запрос, "Секция", СтруктураАдресаНулевойЯчейки);
	ПоместитьТаблицуЧастейАдреса(Запрос, "Линия", СтруктураАдресаНулевойЯчейки);
	ПоместитьТаблицуЧастейАдреса(Запрос, "Стеллаж", СтруктураАдресаНулевойЯчейки);
	ПоместитьТаблицуЧастейАдреса(Запрос, "Ярус", СтруктураАдресаНулевойЯчейки);
	ПоместитьТаблицуЧастейАдреса(Запрос, "Подход", СтруктураАдресаНулевойЯчейки);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВтВсеЯчейкиСклада.Ссылка,
	               |	Вт_Секция.ИндексУдаленности КАК ИндексУдаленности0,
	               |	Вт_Линия.ИндексУдаленности КАК ИндексУдаленности1,
	               |	Вт_Стеллаж.ИндексУдаленности КАК ИндексУдаленности2,
	               |	Вт_Ярус.ИндексУдаленности КАК ИндексУдаленности3,
	               |	Вт_Подход.ИндексУдаленности КАК ИндексУдаленности4
	               |ПОМЕСТИТЬ ВтЯчекиСИндексомУдаленности
	               |ИЗ
	               |	ВтВсеЯчейкиСклада КАК ВтВсеЯчейкиСклада
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Вт_Секция КАК Вт_Секция
	               |		ПО ВтВсеЯчейкиСклада.Секция = Вт_Секция.ЧастьАдреса
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Вт_Линия КАК Вт_Линия
	               |		ПО ВтВсеЯчейкиСклада.Линия = Вт_Линия.ЧастьАдреса
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Вт_Стеллаж КАК Вт_Стеллаж
	               |		ПО ВтВсеЯчейкиСклада.Стеллаж = Вт_Стеллаж.ЧастьАдреса
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Вт_Ярус КАК Вт_Ярус
	               |		ПО ВтВсеЯчейкиСклада.Ярус = Вт_Ярус.ЧастьАдреса
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Вт_Подход КАК Вт_Подход
	               |		ПО ВтВсеЯчейкиСклада.Подход = Вт_Подход.ЧастьАдреса";
				   
	Запрос.Выполнить();
	
КонецПроцедуры
&НаСервереБезКонтекста
Процедура ПоместитьТаблицуЧастейАдреса(Запрос, ЧастьАдреса, СтруктураАдресаНулевойЯчейки)
	
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	&ЧастьАдреса КАК ЧастьАдреса,
	               |	0 КАК ИндексУдаленности
	               |ИЗ
	               |	ВтВсеЯчейкиСклада КАК ВтВсеЯчейкиСклада
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ЧастьАдреса";
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ЧастьАдреса", ЧастьАдреса);
	
	ТаблицаЧастейАдреса = Запрос.Выполнить().Выгрузить();
	
	ИндексЧастиАдресаНулевойЯчейки = 0;
	СтрокаНулевойЯчеки = ТаблицаЧастейАдреса.Найти(СтруктураАдресаНулевойЯчейки[ЧастьАдреса], "ЧастьАдреса"); 
	Если СтрокаНулевойЯчеки <> Неопределено Тогда 
		ИндексЧастиАдресаНулевойЯчейки = ТаблицаЧастейАдреса.Индекс(СтрокаНулевойЯчеки);
		Если ИндексЧастиАдресаНулевойЯчейки < 0 Тогда 
			ИндексЧастиАдресаНулевойЯчейки = 0;
		КонецЕсли;
	КонецЕсли;

	
	КоличествоРазличныхЧастей = ТаблицаЧастейАдреса.Количество();
	МаксимальныйИндекс = КоличествоРазличныхЧастей -1;
	
	ИндексВерх = ИндексЧастиАдресаНулевойЯчейки;
	ИндексНиз = ИндексЧастиАдресаНулевойЯчейки;
	ВсеЭлементыОбработаны_Верх = Ложь;
	ВсеЭлементыОбработаны_Низ = Ложь;
	
	ИндексУдаленности = 0;
	Если КоличествоРазличныхЧастей > 0 Тогда 
		Для Сч = 0 по КоличествоРазличныхЧастей Цикл 
			
			Если ВсеЭлементыОбработаны_Верх И ВсеЭлементыОбработаны_Низ Тогда 
				Прервать;
			КонецЕсли;
			
			Если Не ВсеЭлементыОбработаны_Верх Тогда
				СтрТЗ_ТаблицаЧастейАдреса = ТаблицаЧастейАдреса[ИндексВерх];
				СтрТЗ_ТаблицаЧастейАдреса.ИндексУдаленности = ИндексУдаленности;
			КонецЕсли;
			
			Если Не ВсеЭлементыОбработаны_Низ Тогда 
				СтрТЗ_ТаблицаЧастейАдреса = ТаблицаЧастейАдреса[ИндексНиз];
				СтрТЗ_ТаблицаЧастейАдреса.ИндексУдаленности = ИндексУдаленности;
			КонецЕсли;
			
			Если ИндексВерх <= 0 Тогда 
				ВсеЭлементыОбработаны_Верх = Истина;
			КонецЕсли;
			
			Если ИндексНиз >= МаксимальныйИндекс Тогда 
				ВсеЭлементыОбработаны_Низ = Истина;
			КонецЕсли;
			
			ИндексВерх = ИндексВерх - 1;
			ИндексНиз = ИндексНиз +1;
			ИндексУдаленности = ИндексУдаленности +1;
					
		КонецЦикла;
		
	КонецЕсли;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ИмяЧастиАдреса.ЧастьАдреса КАК ЧастьАдреса,
	               |	ИмяЧастиАдреса.ИндексУдаленности КАК ИндексУдаленности
	               |ПОМЕСТИТЬ ВтИмяЧастиАдреса
	               |ИЗ
	               |	&ТаблицаЧастей КАК ИмяЧастиАдреса";
				   
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "ИмяЧастиАдреса", "_"+ЧастьАдреса);
	Запрос.УстановитьПараметр("ТаблицаЧастей", ТаблицаЧастейАдреса);

	Запрос.Выполнить();
	
КонецПроцедуры
&НаСервереБезКонтекста
Процедура ВыполнитьЗапрос_ВсеЯчейкиСклада(Запрос, Склад)
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	СкладскиеЯчейки.Ссылка,
	               |	СкладскиеЯчейки.Секция,
	               |	СкладскиеЯчейки.Линия,
	               |	СкладскиеЯчейки.Стеллаж,
	               |	СкладскиеЯчейки.Ярус,
	               |	СкладскиеЯчейки.Подход
	               |ПОМЕСТИТЬ ВтВсеЯчейкиСклада
	               |ИЗ
	               |	Справочник.СкладскиеЯчейки КАК СкладскиеЯчейки
	               |ГДЕ
	               |	НЕ СкладскиеЯчейки.ПометкаУдаления
	               |	И НЕ СкладскиеЯчейки.ЭтоГруппа
	               |	И СкладскиеЯчейки.Владелец = &Склад";
	Запрос.УстановитьПараметр("Склад", Склад);	
	Запрос.Выполнить();	   
				   
КонецПроцедуры
