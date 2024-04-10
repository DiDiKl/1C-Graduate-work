
#Область Сервис

Функция ОкладНеУстановлен(Оклад, ФИО, НомерСтроки, Отказ)
	Если Оклад = 0 Тогда
		Отказ = Истина;
		Сообщить("Оклад для сотрудника """+ФИО+""" в строке №"+НомерСтроки+" не установлен. См. регистр ""Сведения о сотрудниках""");
	КонецЕсли;
	Возврат Отказ;
КонецФункции   

#КонецОбласти

Процедура ОбработкаПроведения(Отказ, Режим) 
	
	ОсновНачПВР = ПланыВидовРасчета.ОсновныеНачисления;
	ДопНачПВР = ПланыВидовРасчета.ДополнительныеНачисления; 
	НалогиПВР = ПланыВидовРасчета.Налоги;
	
	#Область ЗаписьДвижений
	Движения.ОсновныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаНачисления Из Начисления Цикл
		Движение = Движения.ОсновныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ПериодРегистрации = Дата;
		Движение.ПериодДействияНачало = ТекСтрокаНачисления.ДатаНачала;
		Движение.ПериодДействияКонец = ТекСтрокаНачисления.ДатаОкончания;
		Движение.ВидРасчета = ТекСтрокаНачисления.ВидНачисления;
		Движение.Сотрудник = ТекСтрокаНачисления.Сотрудник;
		Движение.Должность = ТекСтрокаНачисления.Должность;
		Движение.График = ТекСтрокаНачисления.График;
	КонецЦикла;
	 
	Движения.ДополнительныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаНачисления Из ДополнительныеНачисления Цикл
		Движение = Движения.ДополнительныеНачисления.Добавить();
		Движение.Сторно = Ложь; 
		Движение.ПериодРегистрации = Дата;
		Движение.ПериодРасчета = НачалоМесяца(ПериодРасчета);
		Движение.ВидРасчета = ТекСтрокаНачисления.ВидНачисления;
		Если Движение.ВидРасчета = ДопНачПВР.Премия Тогда
	        Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(ПериодРасчета, -1));
			Движение.БазовыйПериодКонец = КонецМесяца(Движение.БазовыйПериодНачало);
		Иначе	
			Движение.БазовыйПериодНачало = НачалоМесяца(ПериодРасчета);
			Движение.БазовыйПериодКонец = КонецМесяца(ПериодРасчета);    
		КонецЕсли;
		Движение.Сотрудник = ТекСтрокаНачисления.Сотрудник;
		Движение.Должность = ТекСтрокаНачисления.Должность;
		Движение.Размер = ТекСтрокаНачисления.Размер;
	КонецЦикла;
	
	Движения.НалоговыеОтчисления.Записывать = Истина;
	Запрос = Новый Запрос;
	#Область ТекстЗапросаДвижНДФЛ
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НачислениеЗарплатыНачисления.Сотрудник КАК Сотрудник,
		|	НачислениеЗарплатыНачисления.Должность КАК Должность
		|ИЗ
		|	Документ.НачислениеЗарплаты.Начисления КАК НачислениеЗарплатыНачисления
		|ГДЕ
		|	НачислениеЗарплатыНачисления.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	НачислениеЗарплатыНачисления.Сотрудник,
		|	НачислениеЗарплатыНачисления.Должность
		|
		|ОБЪЕДИНИТЬ
		|
		|ВЫБРАТЬ
		|	НачислениеЗарплатыДополнительныеНачисления.Сотрудник,
		|	НачислениеЗарплатыДополнительныеНачисления.Должность
		|ИЗ
		|	Документ.НачислениеЗарплаты.ДополнительныеНачисления КАК НачислениеЗарплатыДополнительныеНачисления
		|ГДЕ
		|	НачислениеЗарплатыДополнительныеНачисления.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	НачислениеЗарплатыДополнительныеНачисления.Сотрудник,
		|	НачислениеЗарплатыДополнительныеНачисления.Должность";
	#КонецОбласти
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();//РезультатЗапроса.Выгрузить()
	Пока Выборка.Следующий() Цикл
		Движение = Движения.НалоговыеОтчисления.Добавить();
		Движение.Сторно = Ложь; 
		Движение.ПериодРегистрации = Дата;
		Движение.ПериодРасчета = НачалоМесяца(ПериодРасчета);
		Движение.БазовыйПериодНачало = НачалоМесяца(ПериодРасчета);
		Движение.БазовыйПериодКонец = КонецМесяца(ПериодРасчета);
		Движение.ВидРасчета = НалогиПВР.НДФЛ;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.Должность = Выборка.Должность;
	КонецЦикла;
	
	Движения.Записать();
    #КонецОбласти 
	
	#Область РасчетыОсновныхНачислений
	Запрос = Новый Запрос;
	#Область ТекстЗапросаОснНач
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
		|	ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник,
		|	ОсновныеНачисленияДанныеГрафика.Сотрудник.Представление КАК ФИО,
		|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеЧасыПериодДействия, 1) КАК ПланЧасы,
		|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеЧасыФактическийПериодДействия, 0) КАК ФактЧасы,
		|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеДниФактическийПериодДействия, 0) КАК ФактДни,
		|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеДниПериодДействия, 1) КАК ПланДни,
		|	ЕСТЬNULL(ОкладыСотрудниковСрезПоследних.Оклад, 0) КАК Оклад
		|ИЗ
		|	РегистрРасчета.ОсновныеНачисления.ДанныеГрафика(Регистратор = &СсылкаДок) КАК ОсновныеНачисленияДанныеГрафика
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СведенияОСотрудниках.СрезПоследних(&Дата, ) КАК ОкладыСотрудниковСрезПоследних
		|		ПО ОсновныеНачисленияДанныеГрафика.Сотрудник = ОкладыСотрудниковСрезПоследних.Сотрудник
		|			И ОсновныеНачисленияДанныеГрафика.Должность = ОкладыСотрудниковСрезПоследних.Должность";
	#КонецОбласти //ТекстЗапроса
	Запрос.УстановитьПараметр("СсылкаДок", Ссылка);
	Запрос.УстановитьПараметр("Дата", НачалоМесяца(ПериодРасчета));
	
	РезультатЗапроса = Запрос.Выполнить(); 
	Выборка = РезультатЗапроса.Выбрать(); 
	Для каждого ЗаписьДвиж Из Движения.ОсновныеНачисления Цикл
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(ЗаписьДвиж.НомерСтроки, "НомерСтроки") Тогда
			Если ОкладНеУстановлен(Выборка.Оклад, Выборка.ФИО, ЗаписьДвиж.НомерСтроки, Отказ) Тогда
				Продолжить;
			КонецЕсли;
			
			Если ЗаписьДвиж.ВидРасчета = ОсновНачПВР.Оклад Тогда 
				ЗаписьДвиж.Размер = Выборка.Оклад;
				ЗаписьДвиж.Результат = Выборка.ФактЧасы / Выборка.ПланЧасы * Выборка.Оклад;
				ЗаписьДвиж.Факт = Выборка.ФактЧасы;
				ЗаписьДвиж.План = Выборка.ПланЧасы;
				ЗаписьДвиж.ЕдиницыИзмерения = Перечисления.ЕдиницыИзмеренияВремени.Час; 
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;
	Если Отказ Тогда
	    Возврат;
	КонецЕсли;
	Движения.ОсновныеНачисления.Записать(, Истина);
	
	#КонецОбласти
	///////////////////////////////////////////////////////////////
	СписокИзмерений = Новый Массив;
	СписокИзмерений.Добавить("Сотрудник");
	СписокИзмерений.Добавить("Должность");
	
	#Область РасчетыДопНачислений
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(ДопНачБазаОснНач.НомерСтроки, ДопНачБазаДопНач.НомерСтроки) КАК НомерСтроки,
		|	ЕСТЬNULL(ДопНачБазаОснНач.РезультатБаза, 0) КАК РезультатОснов,
		|	ЕСТЬNULL(ДопНачБазаДопНач.РезультатБаза, 0) КАК РезультатДоп
		|ИЗ
		|	РегистрРасчета.ДополнительныеНачисления.БазаОсновныеНачисления(&СписокИзмерений, &СписокИзмерений, , Регистратор = &Регистратор) КАК ДопНачБазаОснНач
		|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрРасчета.ДополнительныеНачисления.БазаДополнительныеНачисления(&СписокИзмерений, &СписокИзмерений, , Регистратор = &Регистратор) КАК ДопНачБазаДопНач
		|		ПО ДопНачБазаОснНач.НомерСтроки = ДопНачБазаДопНач.НомерСтроки";
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	Запрос.УстановитьПараметр("СписокИзмерений", СписокИзмерений); 
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();//РезультатЗапроса.Выгрузить()
	Для каждого ЗаписьДвиж Из Движения.ДополнительныеНачисления Цикл
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(ЗаписьДвиж.НомерСтроки, "НомерСтроки") Тогда
			Если ЗаписьДвиж.ВидРасчета = ДопНачПВР.Премия Тогда
				Если ЗаписьДвиж.Размер = 0 Тогда
					ЗаписьДвиж.Размер = 100;
				КонецЕсли;
				ЗаписьДвиж.Результат = ЗаписьДвиж.Размер / 100 * (Выборка.РезультатОснов + Выборка.РезультатДоп);
				
			ИначеЕсли ЗаписьДвиж.ВидРасчета = ДопНачПВР.ПодарокПремия	Тогда
				ЗаписьДвиж.Результат = ЗаписьДвиж.Размер;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Движения.ДополнительныеНачисления.Записать(, Истина);
	#КонецОбласти
	
	#Область РасчетНалоги
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(НалогиОснНач.НомерСтроки, НалогиДопНач.НомерСтроки) КАК НомерСтроки,
		|	ЕСТЬNULL(НалогиОснНач.РезультатБаза, 0) + ЕСТЬNULL(НалогиДопНач.РезультатБаза, 0) КАК Результат
		|ИЗ
		|	РегистрРасчета.НалоговыеОтчисления.БазаОсновныеНачисления(&СписокИзмерений, &СписокИзмерений, , Регистратор = &Регистратор) КАК НалогиОснНач
		|		ПОЛНОЕ СОЕДИНЕНИЕ РегистрРасчета.НалоговыеОтчисления.БазаДополнительныеНачисления(&СписокИзмерений, &СписокИзмерений, , Регистратор = &Регистратор) КАК НалогиДопНач
		|		ПО НалогиОснНач.НомерСтроки = НалогиДопНач.НомерСтроки";
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	Запрос.УстановитьПараметр("СписокИзмерений", СписокИзмерений); 
	
	РазмерНДФЛ = Константы.РазмерНДФЛ.Получить();
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();//РезультатЗапроса.Выгрузить()
	Для каждого ЗаписьДвиж Из Движения.НалоговыеОтчисления Цикл
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(ЗаписьДвиж.НомерСтроки, "НомерСтроки") Тогда
			Если ЗаписьДвиж.ВидРасчета = НалогиПВР.НДФЛ Тогда
				ЗаписьДвиж.Размер = РазмерНДФЛ;
				ЗаписьДвиж.Результат = РазмерНДФЛ / 100 * Выборка.Результат;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	Движения.НалоговыеОтчисления.Записать(, Истина);	
	#КонецОбласти  
	
КонецПроцедуры  
