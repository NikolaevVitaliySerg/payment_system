create or replace package body payment_api_pack is  

    g_is_api boolean := false; -- признак выполняется ли изменения через API
    
    procedure allow_changes is
    begin
        g_is_api := true;
    end;

    procedure disallow_changes is
    begin
        g_is_api := false;
    end;
    
    -- Создание платежа
    function create_payment (p_payment_detail t_payment_detail_array
                                              ,p_summa payment.summa%type
                                              ,p_currency_id payment.currency_id%type
                                              ,p_from_client_id payment.from_client_id%type
                                              ,p_to_client_id payment.to_client_id%type
                                              ,p_create_dtime payment.create_dtime%type default systimestamp
    ) 
    return payment.payment_id%type 
    is
        v_payment_id payment.payment_id%type; 
    begin
        if p_payment_detail is not empty then 
             for i in p_payment_detail.first..p_payment_detail.last loop
    
                if (p_payment_detail(i).field_id is null) then
                    raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_field_id);
                end if;  
    
                if (p_payment_detail(i).field_value is null) then
                    raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_field_value);
                end if;
                
            end loop;
        else 
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_collection);
        end if;
        
        allow_changes();
        
        -- Создание платежа
        insert into payment (payment_id
                            ,create_dtime
                            ,summa
                            ,currency_id
                            ,from_client_id
                            ,to_client_id
                            ,status
                            ,status_change_reason)
        values (payment_seq.nextval, p_create_dtime, p_summa, p_currency_id, p_from_client_id, p_to_client_id, c_payment_created, null)
        returning payment_id into v_payment_id;

        -- Добавление деталей платежа
        payment_detail_api_pack.insert_or_update_payment_detail(v_payment_id, p_payment_detail); 
        
        disallow_changes();
        
        return v_payment_id;
    exception 
        when others then
            disallow_changes();
            raise;
    end;
    
    -- Сброс платежа
    procedure fail_payment (p_payment_id payment.payment_id%type
                                             ,p_reason payment.status_change_reason%type)
    is
    begin
        if p_payment_id is null then
             raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_object_id);
        end if;
    
         if p_reason is null then
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_reason);
         end if;

        try_lock_payment(p_payment_id);

        allow_changes();
        
        -- Сброс платежа в ошибочный статус
        update payment p
            set p.status = c_error_posting_payment
                ,p.status_change_reason = p_reason
            where payment_id = p_payment_id
               and p.status = c_payment_created;     
               
        disallow_changes();
        
    exception 
        when others then
            disallow_changes();
            raise;
    end;
    
    -- Отмена платежа
    procedure cancel_payment (p_payment_id payment.payment_id%type
                                                ,p_reason payment.status_change_reason%type)
    is
    begin
        if p_payment_id is null then
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_object_id);
        end if;
    
        if p_reason is null then
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_reason);
        end if;
        
        try_lock_payment(p_payment_id);
        
        allow_changes();
        
         -- Отмена платежа
        update payment p
            set p.status = c_payment_cancel
                ,p.status_change_reason = p_reason
            where payment_id = p_payment_id
               and p.status = c_payment_created;
               
        disallow_changes();
        
    exception 
        when others then
            disallow_changes();
            raise;
    end;
    
    -- Успешное завершение платежа
    procedure successful_finish_payment (p_payment_id payment.payment_id%type)
    is 
    begin
        if p_payment_id is null then
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_object_id);
        end if;

        try_lock_payment(p_payment_id);

        allow_changes();
        
        -- Завершение платежа
        update payment p
            set p.status = c_payment_posting
            where payment_id = p_payment_id
               and p.status = c_payment_created;
               
        disallow_changes();
        
    exception 
        when others then
            disallow_changes();
            raise;
    end;
    
    procedure is_changes_through_api is
    begin
        if not g_is_api and not common_pack.is_manual_change_allowed() then
          raise_application_error(common_pack.c_error_code_manual_changes,
                                  common_pack.c_error_msg_manual_changes);
        end if;
    end;

    procedure check_payment_delete_restriction 
    is
    begin
        if not common_pack.is_manual_change_allowed() then
          raise_application_error(common_pack.c_error_code_delete_forbidden, common_pack.c_error_msg_delete_forbidden);
        end if;
    end;
    
    procedure try_lock_payment(p_payment_id payment.payment_id%type) 
    is
    v_status payment.status%type;
    begin
        -- Пытаемся заблокировать платеж
         select status 
          into v_status
           from payment t 
        where t.payment_id = p_payment_id
          for update nowait;
        
        if v_status != c_payment_created then
          -- Платеж уже в финальном статусе. С ним нельзя работать
          raise_application_error(common_pack.c_error_code_last_status_object, common_pack.c_error_msg_last_status_object);
        end if;
    exception
        when no_data_found then -- такой платеж вообще не найден
            raise_application_error(common_pack.c_error_code_object_notfound, common_pack.c_error_msg_object_notfound); 
        when common_pack.e_row_locked then -- объект не удалось заблокировать
            raise_application_error(common_pack.c_error_code_object_already_locked, common_pack.c_error_msg_object_already_locked);
  end;
end;
/
