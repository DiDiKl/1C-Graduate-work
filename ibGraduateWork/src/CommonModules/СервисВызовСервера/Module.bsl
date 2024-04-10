
// Возвращает цену указанной номенклатуры с указанным выдом цены.
// Параметры:
//  Номенклатура  - СправочникСсылка.Номенклатура - Искомая номенклатура
//  ВидЦены  - СправочникСсылка.ВидыЦен - Вид цены номенклатуры 
//  Период   - Дата - Дата на которую нужна цена. Если значение не задано, будет использоваться текущая дата.
// Возвращаемое значение:
//  Число   - Цена номенклатуры, если цена не установлена, значение 0.
Функция ПолучитьЦенуНоменклатуры(Номенклатура, ВидЦены, Валюта, Период = Неопределено) Экспорт 
	Отбор = Новый Структура("Номенклатура,ВидЦены,Валюта", Номенклатура, ВидЦены, Валюта);
	ПериодДата = ?(ЗначениеЗаполнено(Период), Период, ТекущаяДата());
	НоменРег = РегистрыСведений.ЦеныНоменклатуры.ПолучитьПоследнее(ПериодДата, Отбор);
	Возврат НоменРег.Цена;
КонецФункции // ЦенаНоменклатуры()

// Функция - Получить цены номенклатур
// Принимает массив Номенклатур и возвращает массив с их ценами.
// Параметры:
//  Номенклатуры - Массив - Массив с номенклатурами (СправочникСсылка.Номенклатура).
//  ВидЦены		 - СправочникСсылка.ВидыЦен - Вид возвращаемой цены.
//  Период   - Дата - Дата на которую нужна цена. Если значение не задано, будет использоваться текущая дата.
// Возвращаемое значение:
//  Массив - Массив содержит цены номенклатур в порядке номенклатур в переданном массиве-списке. Значение 0 если цена для номенклатуры не установлена.
Функция ПолучитьЦеныНоменклатур(Знач СписокНоменклатуры, ВидЦены, Валюта, Период = Неопределено) Экспорт
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныНоменклатурыСрезПоследних.Номенклатура КАК Номенклатура,
		|	ЦеныНоменклатурыСрезПоследних.Цена КАК Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|			&Период,
		|			ВидЦены = &ВидЦены
		|				И Валюта = &Валюта
		|				И Номенклатура В (&СписокНоменклатуры)) КАК ЦеныНоменклатурыСрезПоследних";
	Запрос.УстановитьПараметр("Период", ?(ЗначениеЗаполнено(Период), Период, ТекущаяДата()));
	Запрос.УстановитьПараметр("ВидЦены", ВидЦены);
	Запрос.УстановитьПараметр("Валюта", Валюта);
	Запрос.УстановитьПараметр("СписокНоменклатуры", СписокНоменклатуры);
	
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	МасЦены = Новый Массив();
	Для каждого Номен Из СписокНоменклатуры Цикл
		Выборка.Сбросить();
		Цена = ?(Выборка.НайтиСледующий(Номен, "Номенклатура"), Выборка.Цена, 0);
		МасЦены.Добавить(Цена);
	КонецЦикла;
	Возврат МасЦены; 
КонецФункции  

// Функция - Получить курс валюты
// Возвращает курс валюты.
// Параметры:
//  Валюта	 - СправочникСсылка	- Валюта, курс которой будет возвращен.
//  Период	 - Дата	- Период на который требуется курс. Если значение не задано, будет использоваться текущая дата.
// Возвращаемое значение:
//  Число - Курс валюты. 0 если у валюты не задан курс.
Функция ПолучитьКурсВалюты(Валюта, Период=Неопределено) Экспорт
	Отбор = Новый Структура("Валюта", Валюта);
	ПериодДата = ?(ЗначениеЗаполнено(Период), Период, ТекущаяДата());	
	КсВт = РегистрыСведений.КурсыВалют.ПолучитьПоследнее(ПериодДата, Отбор);	
    Возврат КсВт.Курс;
КонецФункции // ПолучитьКурсВалюты()

// Функции - Курсы валюты
// Возвращает курсы валют на указаннйю дату.
// Параметры:
//  Валюты  - СправочникСсылка.Вылюты, Массив - Массив валют, или ссылка на одну валюту.
//  Период  	- Дата - Период за который необходиом курс. Если параметр не указан, будет использоваться текущая дата.
//  СообщенитьЕслиНетКурса - Булево - Если Истина то будет выведено сообщение об отсутствии курса у валюты.
//  НетКурса - Булево - Возвращает Истина если для одной из валют не установлен курс.
// Возвращаемое значение:
//   Массив - Массив структур с курсами валют в той же последовательности что и переданном массиве Валюты. 
//   Если курс для валюты не установден, будет иметь значение 0. Структура имет свойства "Ваюта" и "Курс".
Функция ПолучитьКурсыВалют(Знач Валюты, Период=Неопределено, СообщенитьЕслиНетКурса=Ложь, НетКурса=Ложь) Экспорт 
	Если Не ЗначениеЗаполнено(Валюты) Тогда
		Возврат Новый Массив;
	КонецЕсли;
	Если ТипЗнч(Валюты) = Тип("СправочникСсылка.Валюты") Тогда			
		МсВалюты = Новый Массив;
		МсВалюты.Добавить(Валюты);
	Иначе
		МсВалюты = Валюты;	
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КурсыВалютСрезПоследних.Валюта КАК Валюта,
		|	КурсыВалютСрезПоследних.Курс КАК Курс
		|ИЗ
		|	РегистрСведений.КурсыВалют.СрезПоследних(&Период, Валюта В (&Валюты)) КАК КурсыВалютСрезПоследних";
	Запрос.УстановитьПараметр("Валюты", МсВалюты);
	Запрос.УстановитьПараметр("Период", ?(ЗначениеЗаполнено(Период), Период, ТекущаяДата()));
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	МсВалютыКурсы = Новый Массив;
	Для каждого Вал Из МсВалюты Цикл
		ВалКур = Новый Структура("Валюта, Курс");
		ВалКур.Валюта = Вал; 
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(Вал, "Валюта") Тогда
			ВалКур.Курс = Выборка.Курс;
		Иначе	
			ВалКур.Курс = 0;
			НетКурса = Истина;
			Если СообщенитьЕслиНетКурса Тогда
				Сообщить(СтрШаблон("Курс для валюты ""%1"" не установлен.", Вал.Наименование));
			КонецЕсли;
		КонецЕсли;
		МсВалютыКурсы.Добавить(ВалКур);
	КонецЦикла;
	Возврат МсВалютыКурсы;
КонецФункции // КурсыВалюты() 

// Функция - Получить коэффициент перевода и курсы валют
// Возвращает структуру с коэффициентом, который можно использовать для перевода валюты. 
// Формула: (Сумма конвертируемой валюты) * (Коэффициент)
// Свойства структуры: "Кфф"=коэффициент, "КурсВалютыИз", "КурсВалютыВ".
// Параметры:
//  ВалютаИз	- СправочникСсылка.Вылюты - Валюта из которой нужно конвертировать значение.
//  ВалютаВ		- СправочникСсылка.Вылюты - Валюта в которую нужно конвертировать значение.
//  Период		- Дата - Период за который необходиом курс. Если параметр не указан, будет использоваться текущая дата.
//  СообщенитьЕслиНетКурса - Булево - Если Истина то будет выведено сообщение об отсутствии курса у валюты.
//  НетКурса 	- Булево - Возвращает Истина если для одной из валют не установлен курс.
// Возвращаемое значение:
//  Структура - Свойство "Кфф" для конвертации валюты. 0 если у одной из валют нет курса.  
//	Свойства: "Кфф"=коэффициент, "КурсВалютыИз", "КурсВалютыВ". 
Функция ПолучитьКоэффициентПереводаКурсыВалют(ВалютаИз, ВалютаВ, Период=Неопределено, СообщенитьЕслиНетКурса=Ложь, НетКурса=Ложь) Экспорт
	Валюты = Новый Массив;
	Валюты.Добавить(ВалютаИз);
	Валюты.Добавить(ВалютаВ);
	КурсыВал = ПолучитьКурсыВалют(Валюты, Период, СообщенитьЕслиНетКурса, НетКурса);
	СтПеревод = Новый Структура("Кфф,КурсВалютыИз,КурсВалютыВ");
	СтПеревод.Вставить("КурсВалютыИз", КурсыВал[0].Курс);
	СтПеревод.Вставить("КурсВалютыВ", КурсыВал[1].Курс);
	СтПеревод.Вставить(
		"Кфф", 
		?(НетКурса, 0, ?(ВалютаИз=ВалютаВ, 1, СтПеревод.КурсВалютыИз / СтПеревод.КурсВалютыВ))
	);
	Возврат СтПеревод;	
КонецФункции // ПолучитьКоэффициентВалют()

// Функция - Получить коэффициент перевода валюты в учетную валюту
// Принимает валюту из которой нужно перевести, и возвращает коффициент для расчета суммы в валюте учета.
// Коэффициент является курсом валюты (сумма в учетной валюте). 
// Формула: (Сумма в изначальной валюте) * коэффициент = Сумма в валюте учета.
// Параметры:
//  Валюта					 - СправочникСсылка - Изначальная валюта.
//  Период					 - Дата	- Период на который берутся курсы валют.
//  СообщенитьЕслиНетКурса	 - Булево - Если Истина то будет выведено сообщение об отсутствии курса у валюты.
//  НетКурса 				 - Булево - Возвращает Истина если для одной из валют не установлен курс.
// Возвращаемое значение:
//  Число - Коэффициент. 0 если у валюты нет курса.
Функция ПолучитьКоэффициентПереводаВалютыВУчетнуюВалюту(Валюта, Период, СообщенитьЕслиНетКурса=Ложь, НетКурса=Ложь) Экспорт
	ВалютаУчета = Константы.ВалютаУчета.Получить();
	Если Валюта = ВалютаУчета Тогда
		Возврат 1;
	Иначе	
	    Курс = ПолучитьКурсВалюты(Валюта, Период);
		Если Курс = 0 Тогда
			НетКурса = Истина;
			Если СообщенитьЕслиНетКурса Тогда
				Сообщить(СтрШаблон("Курс для валюты ""%1"" не установлен.", Валюта.Наименование));
			КонецЕсли;
		КонецЕсли;
		Возврат Курс;
	КонецЕсли;
КонецФункции // ПолучитьКоэффициентДляПереводаВалюты()  

// Функция - Получить список должностей на сервере
// Возвращает список всех должностей, или если установлен параметр Сотрудник, список должностей сотрудника.
// Параметры:
//  Сотрудник		 - СправочникСсылка.ФизическиеЛица - Сотрудник, должности которого нужно получить.
//  ТакжеСписокВсех	 - Булево - Указывает нужно ли получить дополнительно второй список всех должностей помимо сотрудника.
// Возвращаемое значение:
//  Массив - 1) Вернет список всех должностей если Сотрудник не указан. 2) Если Сотрудник указан вернет список его должностей.   
//  3) Если Сотрудник указан и параметр ТакжеСписокВсех установлен в Истина, вернет массив с двумя списками. 
//  Первый элемент список должностей сотрудника, второй список всех должностей.
Функция ПолучитьСписокДолжностей(Сотрудник=Неопределено, ТакжеСписокВсех=Ложь) Экспорт
	Если Сотрудник = Неопределено Тогда
		Выборка = Справочники.Должности.Выбрать();
		ДолжностиВсе = Новый Массив();
		Пока Выборка.Следующий() Цикл 
			ДолжностиВсе.Добавить(Выборка.Ссылка);
		КонецЦикла;
	    Возврат ДолжностиВсе;
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Должности.Ссылка КАК Должность,
		|	ЕСТЬNULL(СведенияОСотрудникахСрезПоследних.Оклад, 0) <> 0 КАК Назначен
		|ИЗ
		|	Справочник.Должности КАК Должности
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СведенияОСотрудниках.СрезПоследних(, Сотрудник = &Сотрудник) КАК СведенияОСотрудникахСрезПоследних
		|		ПО (СведенияОСотрудникахСрезПоследних.Должность = Должности.Ссылка)";
	
	Запрос.УстановитьПараметр("Сотрудник", Сотрудник);
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();//РезультатЗапроса.Выгрузить()
	ДолжностиСотрудника = Новый Массив();
	Если ТакжеСписокВсех Тогда
		ДолжностиВсе = Новый Массив();
		Пока Выборка.Следующий() Цикл 
			ДолжностиВсе.Добавить(Выборка.Должность);
			Если Выборка.Назначен Тогда
				ДолжностиСотрудника.Добавить(Выборка.Должность);
			КонецЕсли;
		КонецЦикла;	
		СпискиДолжностей = Новый Массив();
		СпискиДолжностей.Добавить(ДолжностиСотрудника);
		СпискиДолжностей.Добавить(ДолжностиВсе);
		Возврат СпискиДолжностей; 
	Иначе
		Пока Выборка.Следующий() Цикл 
			Если Выборка.Назначен Тогда
				ДолжностиСотрудника.Добавить(Выборка.Должность);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	Возврат ДолжностиСотрудника;
КонецФункции
