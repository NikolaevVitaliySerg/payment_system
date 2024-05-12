create or replace package payment_detail_api_pack is 
    /*
    Автор: Николаев В.С.
    Описание: API для сущностей "Детали платежа"
    */

    -- Статусы платежа
    c_payment_created constant payment.status%type := 0;
    c_payment_posting constant payment.status%type := 1;
    c_error_posting_payment constant payment.status%type := 2;
    c_payment_cancel constant payment.status%type := 3; 
    
    -- Добавление/обновление данных платежа
    procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type
                              ,p_payment_detail t_payment_detail_array);

    -- Удаление деталей платежа
    procedure delete_payment_detail (p_payment_id payment.payment_id%type 
                                    ,p_delete_payment_detail t_number_array);
    
    -- Выполняются ли изменения через API
    procedure is_changes_through_api;
end;