-- Проверка "Создание платежа"
declare
    v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'Apple pay'),    
                                                                      t_payment_detail(2, '192.158.1.38'),
                                                                      t_payment_detail(3, 'З/п'),
                                                                      t_payment_detail(4, 'Нет'));
    v_payment_id payment.payment_id%type;
    v_summa payment.summa%type := 100;
    v_currency_id payment.currency_id%type := 840;
    v_from_client_id payment.from_client_id%type := 1;
    v_to_client_id payment.to_client_id%type := 1;
    v_create_dtime_tech payment.create_dtime_tech%type;
    v_update_dtime_tech payment.update_dtime_tech%type;  
begin
    v_payment_id := payment_api_pack.create_payment(v_payment_detail, v_summa, v_currency_id, v_from_client_id, v_to_client_id);
    dbms_output.put_line('v_payment_id: '|| v_payment_id);
    
    select pl.create_dtime_tech, pl.update_dtime_tech 
    into v_create_dtime_tech, v_update_dtime_tech
    from payment pl 
    where pl.payment_id = v_payment_id;
  
     -- Проверка работы триггера
     if v_create_dtime_tech != v_update_dtime_tech then
        raise_application_error(-20998, 'Технические даты разные!');
     end if;
     
     commit;
end;
/

-- Проверка "Сброс платежа"
declare 
    v_payment_id payment.payment_id%type := 102;
    v_reason payment.status_change_reason%type := 'Недостаточно средств';
    v_create_dtime_tech payment.create_dtime_tech%type;
    v_update_dtime_tech payment.update_dtime_tech%type;  
begin
    payment_api_pack.fail_payment(v_payment_id, v_reason);
    
    select pl.create_dtime_tech, pl.update_dtime_tech
    into v_create_dtime_tech, v_update_dtime_tech
    from payment pl 
    where pl.payment_id = v_payment_id;
  
     -- Проверка работы триггера
     if v_create_dtime_tech = v_update_dtime_tech then
        raise_application_error(-20998, 'Технические даты равны!');
     end if;
end;
/

-- Проверка "Отмена платежа"
declare 
    v_payment_id payment.payment_id%type := 101;
    v_reason payment.status_change_reason%type := 'Ошибка пользователя';
begin
    payment_api_pack.cancel_payment(v_payment_id, v_reason);
end;
/

-- Проверка "Успешное завершение платежа"
declare 
    v_payment_id payment.payment_id%type := 83;
begin
    payment_api_pack.successful_finish_payment(v_payment_id);
end;
/

-- Проверка "Добавление/обновление данных платежа"
declare 
    v_payment_id payment.payment_id%type := 83;
    v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(4, 'Not'));   
begin
    payment_detail_api_pack.insert_or_update_payment_detail(v_payment_id, v_payment_detail);
end;
/

-- Проверка "Удаление деталей платежа"
declare 
    v_payment_id payment.payment_id%type := 83;
    v_delete_payment_detail t_number_array := t_number_array(1, 2, 3);
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
end;
/

-- Проверка функционала по глобальному разрешению. Операция удаления платежа
declare
  v_payment_id   payment.payment_id%type := -1;
begin
  common_pack.enable_manual_changes();
      
  delete from payment pl where pl.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
  
exception
  when others then
    common_pack.disable_manual_changes();
    raise;    
end;
/

-- Проверка функционала по глобальному разрешению. Операция изменения платежа
declare
  v_payment_id   payment.payment_id%type := -1;
begin
  common_pack.enable_manual_changes();
  
  update payment pl
     set pl.status = pl.status
   where pl.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
  
exception
  when others then
    common_pack.disable_manual_changes();
    raise;    
end;
/

-- Проверка функционала по глобальному разрешению. Операция изменения данных платежа
declare
  v_payment_id   payment.payment_id%type := -1;
begin

  common_pack.enable_manual_changes();
  
  update payment_detail pl
     set pl.field_value = pl.field_value
   where pl.payment_id = v_payment_id;
  
  common_pack.disable_manual_changes();
  
exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/

-- Негативные Unit-тесты
-- Проверка "Создание платежа"
declare
    v_payment_detail t_payment_detail_array;
    v_payment_id payment.payment_id%type;
    v_summa payment.summa%type := 100;
    v_currency_id payment.currency_id%type := 840;
    v_from_client_id payment.from_client_id%type := 1;
    v_to_client_id payment.to_client_id%type := 1;
begin
    v_payment_id := payment_api_pack.create_payment(v_payment_detail, v_summa, v_currency_id, v_from_client_id, v_to_client_id);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception 
    when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Платеж. Создание платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Сброс платежа"
declare 
    v_payment_id payment.payment_id%type;
    v_reason payment.status_change_reason%type := 'Недостаточно средств';
begin
    payment_api_pack.fail_payment(v_payment_id, v_reason);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Платеж. Сброс платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Отмена платежа"
declare 
    v_payment_id payment.payment_id%type := 83;
    v_reason payment.status_change_reason%type;
begin
    payment_api_pack.cancel_payment(v_payment_id, v_reason);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Платеж. Отмена платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Успешное завершение платежа"
declare 
    v_payment_id payment.payment_id%type;
begin
    payment_api_pack.successful_finish_payment(v_payment_id);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Платеж. Успешное завершение платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Добавление/обновление данных платежа"
declare 
    v_payment_id payment.payment_id%type;
    v_payment_detail t_payment_detail_array;   
begin
    payment_detail_api_pack.insert_or_update_payment_detail(v_payment_id, v_payment_detail);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Детали платежа. Добавление/обновление данных платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Удаление деталей платежа" Тест_1
declare 
    v_payment_id payment.payment_id%type;
    v_delete_payment_detail t_number_array := t_number_array(1, 2, 3);
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Детали платежа. Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Удаление деталей платежа" Тест_2
declare 
    v_payment_id payment.payment_id%type := 83;
    v_delete_payment_detail t_number_array := t_number_array();
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Детали платежа. Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Проверка "Удаление деталей платежа" Тест_3
declare 
    v_payment_id payment.payment_id%type := 83;
    v_delete_payment_detail t_number_array;
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
    raise_application_error(-20999, 'Unit тест или API выполнены не верно');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API Детали платежа. Удаление деталей платежа. Исключение возбуждено успешно. Ошибка: ' || sqlerrm);
end;
/

-- Негативные тесты (триггеры)
-- Проверка запрета удаления payment через не через API
declare
  v_payment_id payment.payment_id%type := 1000;
begin
  delete from payment p1 where p1.payment_id = v_payment_id;
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');  
exception
  when common_pack.e_delete_forbidden then
    dbms_output.put_line('Удаление платежа. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/

-- Проверка запрета вставки в payment не через API
declare
    v_payment_id   payment.payment_id%type := 1000;
    v_summa payment.summa%type := 100;
    v_currency_id payment.currency_id%type := 840;
    v_from_client_id payment.from_client_id%type := 1;
    v_to_client_id payment.to_client_id%type := 1;
begin
   insert into payment ( payment_id 
                        ,create_dtime 
                        ,summa
                        ,currency_id
                        ,from_client_id
                        ,to_client_id
                        ,status
                        ,status_change_reason)
        values (v_payment_id, systimestamp, v_summa, v_currency_id, v_from_client_id, v_to_client_id, 1, null);

  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка в таблицу payment не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/

-- Проверка запрета обновления в payment не через API
declare
  v_payment_id   payment.payment_id%type := 1000;
begin
       update payment p
            set p.status = 2
            where payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы payment не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/

-- Вставка не через API - данных платежа
declare
  v_payment_id   payment_detail.payment_id%type := 1000;
  v_field_id    payment_detail.field_id%type := 1000;
begin
  insert into payment_detail(payment_id,
                          field_id,
                          field_value)
  values
    (v_payment_id
    ,v_field_id
    ,null);
  
	raise_application_error(-20999, 'Unit-тест или API выполнены не верно');		
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка в таблицу payment_detail не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/

-- Изменение не через API (обновление) - данных платежа
declare
  v_payment_id   payment_detail.payment_id%type := 1000;
begin
  update payment_detail p1
     set p1.field_value = p1.field_value
   where p1.payment_id = v_payment_id;
  
	raise_application_error(-20999, 'Unit-тест или API выполнены не верно');	 
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы payment_detail не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/

-- Удаление не через API (обновление) - данных платежа
declare
  v_payment_id   payment_detail.payment_id%type := 1000;
begin
  delete payment_detail p1     
   where p1.payment_id = v_payment_id;
  
	raise_application_error(-20999, 'Unit-тест или API выполнены не верно');	 
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Удаление из таблицы payment_detail не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/

-- Негативный тест на отсутствие платежа
declare
  v_payment_id payment.payment_id%type := -777;
  v_reason    payment.status_change_reason%type := 'Тестовая причина';
begin
  payment_api_pack.fail_payment(v_payment_id, v_reason);
  raise_application_error(-20999, 'Unit-тест или API выполнены не верно');	 
exception
  when common_pack.e_object_notfound then 
    dbms_output.put_line('Объект не найден. Исключение возбуждено успешно. Ошибка: '|| sqlerrm); 
end;
/