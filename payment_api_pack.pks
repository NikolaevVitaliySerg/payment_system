create or replace package payment_api_pack is
    /*
    Автор: Николаев В.С.
    Описание: API для сущностей "Платеж"
    */
    
    -- Статусы платежа
    c_payment_created constant payment.status%type := 0;
    c_payment_posting constant payment.status%type := 1;
    c_error_posting_payment constant payment.status%type := 2;
    c_payment_cancel constant payment.status%type := 3;
    
    -- Создание платежа
    function create_payment (p_payment_detail t_payment_detail_array
                            ,p_summa payment.summa%type
                            ,p_currency_id payment.currency_id%type
                            ,p_from_client_id payment.from_client_id%type
                            ,p_to_client_id payment.to_client_id%type
                            ,p_create_dtime payment.create_dtime%type default systimestamp)
    return payment.payment_id%type;
    
    -- Сброс платежа
    procedure fail_payment (p_payment_id payment.payment_id%type
                           ,p_reason payment.status_change_reason%type);
    
    -- Отмена платежа
    procedure cancel_payment (p_payment_id payment.payment_id%type
                             ,p_reason payment.status_change_reason%type);
    
    -- Успешное завершение платежа
    procedure successful_finish_payment (p_payment_id payment.payment_id%type);
    
    -- Блокировка платежа для изменений
    procedure try_lock_payment(p_payment_id payment.payment_id%type);
      
     -- Выполняются ли изменения через API
     procedure is_changes_through_api;

      -- Проверка, на возможность удалять данные
      procedure check_payment_delete_restriction;
      
end;
/
