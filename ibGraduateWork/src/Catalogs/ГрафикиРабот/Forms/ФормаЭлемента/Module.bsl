
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Объект.Ссылка.Пустая() Тогда
	    Для НомерДня = 1 По 5 Цикл
		    ЭтаФорма["День"+НомерДня] = Истина;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	Объект.ВыходныеДни = "";
	Для НомерДня = 1 По 7 Цикл
		Если Не ЭтаФорма["День"+НомерДня] Тогда			
			Объект.ВыходныеДни = Объект.ВыходныеДни + НомерДня;
		КонецЕсли;	
	КонецЦикла; 
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Отказ = Не СправочникСервер.ПроверитьУникальностьНаименования("ГрафикиРабот", Объект);
КонецПроцедуры
