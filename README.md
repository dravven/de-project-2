
	1. Создать справочник стоимости доставки в страны shipping_country_rates из данных, указанных в shipping_country и shipping_country_base_rate, сделайте первичный ключ таблицы — серийный id, то есть серийный идентификатор каждой строчки. Важно дать серийному ключу имя «id». Справочник должен состоять из уникальных пар полей из таблицы shipping.
	2. Создать справочник тарифов доставки вендора по договору shipping_agreement из данных строки vendor_agreement_description через разделитель :.
Названия полей:
		○ agreementid,
		○ agreement_number,
		○ agreement_rate,
		○ agreement_commission.
Agreementid сделайте первичным ключом.
Подсказка:
Учтите, что при функции regexp возвращаются строковые значения, поэтому полезно воспользоваться функцией cast() , чтобы привести полученные значения в нужный для таблицы формат.
	3. Создать справочник о типах доставки shipping_transfer из строки shipping_transfer_description через разделитель :.
Названия полей:
		○ transfer_type,
		○ transfer_model,
		○ shipping_transfer_rate .
Сделайте первичный ключ таблицы — серийный id. Подсказка: Важно помнить про размерность знаков после запятой при выделении фиксированной длины в типе numeric(). Например, если shipping_transfer_rate равен 2.5%, то при миграции в тип numeric(14,2) у вас отбросится 0,5%.
	4. Создать таблицу shipping_info с уникальными доставками shippingid и свяжите её с созданными справочниками shipping_country_rates, shipping_agreement, shipping_transfer и константной информацией о доставке shipping_plan_datetime , payment_amount , vendorid .
Подсказки:
		1. Cвязи с тремя таблицами-справочниками лучше делать внешними ключами — это обеспечит целостность модели данных и защитит её, если нарушится логика записи в таблицы.
		2. Вы уже сделали идентификаторы, когда создавали справочники shipping_transfer и shipping_country_rates. Теперь достаточно взять нужную информацию из shipping, сделать JOIN к этим двум таблицам и получить идентификаторы для миграции.
	5. Создать таблицу статусов о доставке shipping_status и включите туда информацию из лога shipping (status , state). Добавьте туда вычислимую информацию по фактическому времени доставки shipping_start_fact_datetime, shipping_end_fact_datetime . Отразите для каждого уникального shippingid его итоговое состояние доставки.
Подсказки:
		1. Данные в таблице должны отражать максимальный status и state по максимальному времени лога state_datetime в таблице shipping.
		2. shipping_start_fact_datetime — это время state_datetime, когда state заказа перешёл в состояние booked.
		3. shipping_end_fact_datetime — это время state_datetime , когда state заказа перешёл в состояние received.
		4. Удобно использовать оператор with для объявления временной таблицы, потому что можно сохранить информацию по shippingid и максимальному значению state_datetime. Далее при записи информации в shipping_status можно сделать JOIN и дополнить таблицу нужными данными.
	6. Создать представление shipping_datamart на основании готовых таблиц для аналитики и включите в него:
		○ shippingid
		○ vendorid
		○ transfer_type — тип доставки из таблицы shipping_transfer
		○ full_day_at_shipping — количество полных дней, в течение которых длилась доставка. Высчитывается как:shipping_end_fact_datetime-shipping_start_fact_datetime.
			§ is_delay — статус, показывающий просрочена ли доставка. Высчитывается как:shipping_end_fact_datetime >> shipping_plan_datetime → 1 ; 0
		○ is_shipping_finish — статус, показывающий, что доставка завершена. Если финальный status = finished → 1; 0
		○ delay_day_at_shipping — количество дней, на которые была просрочена доставка. Высчитыается как: shipping_end_fact_datetime >> shipping_end_plan_datetime → shipping_end_fact_datetime -− shipping_plan_datetime ; 0).
		○ payment_amount — сумма платежа пользователя
		○ vat — итоговый налог на доставку. Высчитывается как: payment_amount *∗ ( shipping_country_base_rate ++ agreement_rate ++ shipping_transfer_rate) .
profit — итоговый доход компании с доставки. Высчитывается как: payment_amount*∗ agreement_commission.![image](https://user-images.githubusercontent.com/29153803/174437517-2307539a-80f4-40d8-a2d3-4839900f5964.png)
