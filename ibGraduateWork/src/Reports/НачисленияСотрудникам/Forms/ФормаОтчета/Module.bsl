
&НаКлиенте
Процедура УстановитьПараметрПериод()
	Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Месяц").Значение = Дата(ГодПериода, МесяцПериода, 1);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)	
	ГодТек = Год(ТекущаяДата());
	СпВыбГода = Элементы.ГодПериода.СписокВыбора;
	Для ЧисГод = 0 По (ГодТек - 2000) Цикл
		СпВыбГода.Добавить(ГодТек - ЧисГод);
	КонецЦикла;
	СпВыбМесяцев = Элементы.МесяцПериода.СписокВыбора;
	Для ЧисМесяц = 1 По 12 Цикл
		СпВыбМесяцев.Добавить(
			ЧисМесяц, 
			Формат(Дата(2000, ЧисМесяц, 1), "ДФ=MMMM")
		);		
	КонецЦикла;
	
	МесяцДатаПарам = Отчет.КомпоновщикНастроек.Настройки.ПараметрыДанных.Элементы.Найти("Месяц");
	МесяцДатаПарам.Использование = Истина;
	Если ГодПериода = 0 Или МесяцПериода = 0 Тогда
		ГодПериода = Год(ТекущаяДата());
		МесяцПериода = Месяц(ТекущаяДата());
	КонецЕсли;
	УстановитьПараметрПериод();
КонецПроцедуры

&НаКлиенте
Процедура ГодПериодаОбработкаВыбора(Элемент, ВыбранноеЗначение, ДополнительныеДанные, СтандартнаяОбработка)
	Если ГодПериода = ВыбранноеЗначение Тогда
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ГодПериодаПриИзменении(Элемент)	
	УстановитьПараметрПериод();
КонецПроцедуры

&НаКлиенте
Процедура ДатаПериодаОбработкаВыбора(Элемент, ВыбранноеЗначение, ДополнительныеДанные, СтандартнаяОбработка)
	Если МесяцПериода = ВыбранноеЗначение Тогда
		СтандартнаяОбработка = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДатаПериодаПриИзменении(Элемент)
	УстановитьПараметрПериод();
КонецПроцедуры


&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	ЭтаФорма.ВариантМодифицирован = Ложь;
КонецПроцедуры






