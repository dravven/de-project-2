Инструкция по выполнению проекта
Создайте справочник стоимости доставки в страны shipping_country_rates из данных, указанных в shipping_country и shipping_country_base_rate, сделайте первичный ключ таблицы — серийный id, то есть серийный идентификатор каждой строчки. Важно дать серийному ключу имя «id». Справочник должен состоять из уникальных пар полей из таблицы shipping.
Создайте справочник тарифов доставки вендора по договору shipping_agreement из данных строки vendor_agreement_description через разделитель :.
Названия полей:
agreementid,
agreement_number,
agreement_rate,
agreement_commission.
Agreementid сделайте первичным ключом.
Подсказка:
Учтите, что при функции regexp возвращаются строковые значения, поэтому полезно воспользоваться функцией cast() , чтобы привести полученные значения в нужный для таблицы формат.
Создайте справочник о типах доставки shipping_transfer из строки shipping_transfer_description через разделитель :.
Названия полей:
transfer_type,
transfer_model,
shipping_transfer_rate .
Сделайте первичный ключ таблицы — серийный id. Подсказка: Важно помнить про размерность знаков после запятой при выделении фиксированной длины в типе numeric(). Например, если shipping_transfer_rate равен 2.5%, то при миграции в тип numeric(14,2) у вас отбросится 0,5%.
Создайте таблицу shipping_info с уникальными доставками shippingid и свяжите её с созданными справочниками shipping_country_rates, shipping_agreement, shipping_transfer и константной информацией о доставке shipping_plan_datetime , payment_amount , vendorid .
Подсказки:
Cвязи с тремя таблицами-справочниками лучше делать внешними ключами — это обеспечит целостность модели данных и защитит её, если нарушится логика записи в таблицы.
Вы уже сделали идентификаторы, когда создавали справочники shipping_transfer и shipping_country_rates. Теперь достаточно взять нужную информацию из shipping, сделать JOIN к этим двум таблицам и получить идентификаторы для миграции.
Создайте таблицу статусов о доставке shipping_status и включите туда информацию из лога shipping (status , state). Добавьте туда вычислимую информацию по фактическому времени доставки shipping_start_fact_datetime, shipping_end_fact_datetime . Отразите для каждого уникального shippingid его итоговое состояние доставки.
Подсказки:
Данные в таблице должны отражать максимальный status и state по максимальному времени лога state_datetime в таблице shipping.
shipping_start_fact_datetime — это время state_datetime, когда state заказа перешёл в состояние booked.
shipping_end_fact_datetime — это время state_datetime , когда state заказа перешёл в состояние received.
Удобно использовать оператор with для объявления временной таблицы, потому что можно сохранить информацию по shippingid и максимальному значению state_datetime. Далее при записи информации в shipping_status можно сделать JOIN и дополнить таблицу нужными данными.
Создайте представление shipping_datamart на основании готовых таблиц для аналитики и включите в него:
shippingid
vendorid
transfer_type — тип доставки из таблицы shipping_transfer
full_day_at_shipping — количество полных дней, в течение которых длилась доставка. Высчитывается как:shipping_end_fact_datetime-shipping_start_fact_datetime.
is_delay — статус, показывающий просрочена ли доставка. Высчитывается как:shipping_end_fact_datetime >> shipping_plan_datetime → 1 ; 0
is_shipping_finish — статус, показывающий, что доставка завершена. Если финальный status = finished → 1; 0
delay_day_at_shipping — количество дней, на которые была просрочена доставка. Высчитыается как: shipping_end_fact_datetime >> shipping_end_plan_datetime → shipping_end_fact_datetime -− shipping_plan_datetime ; 0).
payment_amount — сумма платежа пользователя
vat — итоговый налог на доставку. Высчитывается как: payment_amount *∗ ( shipping_country_base_rate ++ agreement_rate ++ shipping_transfer_rate) .
profit — итоговый доход компании с доставки. Высчитывается как: payment_amount*∗ agreement_commission.
Подсказки:
Чтобы получить разницу между датами, удобно использовать функцию age() . Для получения целых дней можно использовать функцию date_part(’day’ , ... ) .
При построении витрины нужно соединить ранее созданные таблицы. Вы уже создали внешние ключи в справочниках, и здесь можно заметить, чем они удобны. Если использовать JOIN трёх справочников: shipping_transfer , shipping_country_rates и shipping_agreement — к таблице с внешними ключами shipping_info, то разные идентификаторы внешних ключей могут автоматически подсвечивать возможные связи.
