 
 
// <Описание функции>
// Проверяет существует ли элемент с заданным наименованием в справочнике.
// Параметры:
//  ИмяСправочника - Строка - Имя справочника заданное в конфигурации.
//  Наименование - Строка - Наименование элемента справочника.
//  ВТочности - Булево - Поиск полного совпадения наименования.
//  Владелец - СправочникСсылка - Владелец по которому будет выполнен поиск.
// Возвращаемое значение:
//   Булево   - Истина если элемент существует, иначе Ложь.
Функция СодержитЭлементСТакимНаименованием(ИмяСправочника, Наименование, Владелец=Неопределено) Экспорт 
	ИскомыйЭлемент = Справочники[ИмяСправочника].НайтиПоНаименованию(Наименование, Истина, , Владелец);
	Возврат ЗначениеЗаполнено(ИскомыйЭлемент);
КонецФункции // СодержитЭлементСТакимНаименованием()

Функция СодержитЭлементСЗначениемРеквизита(ИмяСправочника, ИмяРеквизита, ЗначениеРеквизита, Владелец=Неопределено) Экспорт
	ИскомыйЭлемент = Справочники[ИмяСправочника].НайтиПоРеквизиту(ИмяРеквизита, ЗначениеРеквизита, , Владелец);
	Возврат ЗначениеЗаполнено(ИскомыйЭлемент);	
КонецФункции // СодержитЭлемент()

// Функция - Получить валюту счета организации
// Возвращает валюту переданного счета организации.
// Параметры:
//  Счет - СправочникСсылка.СчетаОрганизации - Счет валюту которого нужно получить.
// Возвращаемое значение:
//  СправочникСсылка.Валюты - Валюта счета.
//
Функция ПолучитьВалютуСчетаОрганизации(Счет) Экспорт
	Возврат Счет.Валюта;
КонецФункции // ПолучитьВалютуСчета()
