
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ 
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	Движения.КурсыВалют.Записывать = Истина;
	Для Каждого СтрокаСВ Из СписокВалют Цикл
		Движение = Движения.КурсыВалют.Добавить();
		Движение.Период = Дата;
		Движение.Валюта = СтрокаСВ.Валюта;
		Движение.Курс = СтрокаСВ.Курс;
	КонецЦикла;
КонецПроцедуры
