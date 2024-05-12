create or replace package body payment_detail_api_pack is   

     g_is_api boolean := false; -- признак выполняется ли изменения через API

      procedure allow_changes is
      begin
        g_is_api := true;
      end;
    
      procedure disallow_changes is
      begin
        g_is_api := false;
      end;
      
    -- Добавление/обновление данных платежа 
    procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type
                                              ,p_payment_detail t_payment_detail_array)
    is 
    begin
        if p_payment_id is null then
           raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_object_id);
        end if; 
        
        payment_api_pack.try_lock_payment(p_payment_id);
        
        allow_changes();
        
        -- Добавление/обновление данных платежа
        merge into payment_detail pd 
        using (select p_payment_id payment_id 
                      ,value(t).field_id field_id
                      ,value(t).field_value field_value 
                from table(p_payment_detail) t) n 
                on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
                when matched then
                    update set pd.field_value = n.field_value
                when not matched then
                    insert (payment_id, field_id, field_value) 
                    values (n.payment_id, n.field_id, n.field_value);
        
        disallow_changes();
        
    exception
        when others then
          disallow_changes();
          raise;
    end;
    
    -- Удаление деталей платежа
    procedure delete_payment_detail (p_payment_id payment.payment_id%type
                                    ,p_delete_payment_detail t_number_array)
    is
    begin
        if p_payment_id is null then
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_object_id);
        end if;
    
        if p_delete_payment_detail is empty then 
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_collection);
        end if;
        
         if p_delete_payment_detail is null or p_delete_payment_detail is empty then 
            raise_application_error(common_pack.c_error_code_invalid_input_parameter, common_pack.c_error_msg_empty_collection);
        end if;
        
        payment_api_pack.try_lock_payment(p_payment_id);
        
        allow_changes();
        
        -- Удаление деталей платежа
        delete payment_detail pd
            where pd.payment_id = p_payment_id
               and pd.field_id in (select value(t) from table(p_delete_payment_detail) t);
               
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
    
end;
/
