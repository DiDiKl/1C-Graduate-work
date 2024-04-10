
// Функция - Заполнить
// Заполняет документ кассового ордера на основе документов заказа или поступления товаров.
// Параметры:
//  Документ		 - ДокументОбъект - Документ который нужно заполнить.
//  ДокументОснова	 - ДокументСсылка - Документ с данныим заполнения.
Процедура Заполнить(Документ, ДокументОснова = Неопределено) Экспорт 
	Если ДокументОснова <> Неопределено Тогда
		ТипДокОснов = ТипЗнч(ДокументОснова);
		
		ЗаполнитьДок = (
			ТипДокОснов = Тип("ДокументСсылка.ЗаказКлиента") Или ТипДокОснов = Тип("ДокументСсылка.РеализацияТоваров") Или
			ТипДокОснов = Тип("ДокументСсылка.ЗаказПоставщику") Или ТипДокОснов = Тип("ДокументСсылка.ПоступлениеТоваров")
		); 
		
		Если ЗаполнитьДок Тогда
			Документ.Основание	  = ДокументОснова.Ссылка;
			Документ.Контрагент	  = ДокументОснова.Контрагент; 
			Документ.Договор	  = ДокументОснова.Договор;
			Документ.Валюта		  = ДокументОснова.Валюта;
			Документ.СуммаКОплате = ДокументОснова.ИтоговаяСумма;
			Документ.Сумма 		  = ДокументОснова.ИтоговаяСумма;
		КонецЕсли;
	КонецЕсли;
	Если Документ.Метаданные().Реквизиты.Найти("СчетОрганизации") <> Неопределено Тогда
		Документ.СчетОрганизации = Константы.ОсновнойСчетОрганизации.Получить();
	КонецЕсли;	
КонецПроцедуры

Процедура ПровестиРасход(Документ, Отказ) Экспорт
	Движения = Документ.Движения;
	Движения.Хозрасчетный.Записывать = Истина;
	Движение = Движения.Хозрасчетный.Добавить();
	Движение.Период = Документ.Дата; 
	
	Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Документ.Контрагент;
	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Документ.Договор; 
	
	Валюта = Документ.Валюта;
	ВалютаУчета = Константы.ВалютаУчета.Получить();
	БезналичныйПлатеж = ТипЗнч(Документ) = Тип("ДокументОбъект.СписаниеСРасчетногоСчета");
	Если Валюта = ВалютаУчета Тогда
		Движение.СчетКт = ?(БезналичныйПлатеж, ПланыСчетов.Хозрасчетный.РасчетныеСчета, ПланыСчетов.Хозрасчетный.КассаОрганизации);
		Движение.Сумма = Документ.Сумма;
	Иначе
		Движение.СчетКт = ?(БезналичныйПлатеж, ПланыСчетов.Хозрасчетный.ВалютныеСчета, ПланыСчетов.Хозрасчетный.КассаОрганизацииВал);
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Валюта] = Валюта;
		Движение.СуммаВалютаКт = Документ.Сумма;
		КоэффКонверт = СервисВызовСервера.ПолучитьКоэффициентПереводаВалютыВУчетнуюВалюту(Валюта, Документ.Дата, Истина, Отказ);
		Движение.Сумма = Документ.Сумма * КоэффКонверт;	
	КонецЕсли;
	Если БезналичныйПлатеж Тогда
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.СчетОрганизации] = Документ.СчетОрганизации;
	КонецЕсли;
КонецПроцедуры

Процедура ПровестиПриход(Документ, Отказ) Экспорт 
	Движения = Документ.Движения;
	Движения.Хозрасчетный.Записывать = Истина;
	Движение = Движения.Хозрасчетный.Добавить();
	Движение.Период = Документ.Дата;
	
	Валюта = Документ.Валюта;
	ВалютаУчета = Константы.ВалютаУчета.Получить();
	БезналичныйПлатеж = ТипЗнч(Документ) = Тип("ДокументОбъект.ПоступлениеНаРасчетныйСчет");
	Если Валюта = ВалютаУчета Тогда
		Движение.СчетДт = ?(БезналичныйПлатеж, ПланыСчетов.Хозрасчетный.РасчетныеСчета, ПланыСчетов.Хозрасчетный.КассаОрганизации);
		Движение.Сумма = Документ.Сумма;
	Иначе 
		Движение.СчетДт = ?(БезналичныйПлатеж, ПланыСчетов.Хозрасчетный.ВалютныеСчета, ПланыСчетов.Хозрасчетный.КассаОрганизацииВал);
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Валюта] = Валюта;
		Движение.СуммаВалютаДт = Документ.Сумма;
		КоэффКонверт = СервисВызовСервера.ПолучитьКоэффициентПереводаВалютыВУчетнуюВалюту(Валюта, Документ.Дата, Истина, Отказ);
		Движение.Сумма = Документ.Сумма * КоэффКонверт;
	КонецЕсли;
	Если БезналичныйПлатеж Тогда
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.СчетОрганизации] = Документ.СчетОрганизации;
    КонецЕсли;
		
	Движение.СчетКт = ПланыСчетов.Хозрасчетный.РасчетыСПокупателями;
	Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Контрагент] = Документ.Контрагент;
	Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Договор] = Документ.Договор;	
КонецПроцедуры


Процедура ОснованиеПриИзменении(Объект) Экспорт
	Основание = Объект.Основание;
	Объект.Контрагент 	= Основание.Контрагент;
	Объект.Договор 		= Основание.Договор;
	Объект.Валюта 		= Основание.Валюта;
	Объект.СуммаКОплате = Основание.ИтоговаяСумма;
КонецПроцедуры