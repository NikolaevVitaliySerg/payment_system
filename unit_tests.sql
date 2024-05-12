-- �������� "�������� �������"
declare
    v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'Apple pay'),    
                                                                      t_payment_detail(2, '192.158.1.38'),
                                                                      t_payment_detail(3, '�/�'),
                                                                      t_payment_detail(4, '���'));
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
  
     -- �������� ������ ��������
     if v_create_dtime_tech != v_update_dtime_tech then
        raise_application_error(-20998, '����������� ���� ������!');
     end if;
     
     commit;
end;
/

-- �������� "����� �������"
declare 
    v_payment_id payment.payment_id%type := 102;
    v_reason payment.status_change_reason%type := '������������ �������';
    v_create_dtime_tech payment.create_dtime_tech%type;
    v_update_dtime_tech payment.update_dtime_tech%type;  
begin
    payment_api_pack.fail_payment(v_payment_id, v_reason);
    
    select pl.create_dtime_tech, pl.update_dtime_tech
    into v_create_dtime_tech, v_update_dtime_tech
    from payment pl 
    where pl.payment_id = v_payment_id;
  
     -- �������� ������ ��������
     if v_create_dtime_tech = v_update_dtime_tech then
        raise_application_error(-20998, '����������� ���� �����!');
     end if;
end;
/

-- �������� "������ �������"
declare 
    v_payment_id payment.payment_id%type := 101;
    v_reason payment.status_change_reason%type := '������ ������������';
begin
    payment_api_pack.cancel_payment(v_payment_id, v_reason);
end;
/

-- �������� "�������� ���������� �������"
declare 
    v_payment_id payment.payment_id%type := 83;
begin
    payment_api_pack.successful_finish_payment(v_payment_id);
end;
/

-- �������� "����������/���������� ������ �������"
declare 
    v_payment_id payment.payment_id%type := 83;
    v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(4, 'Not'));   
begin
    payment_detail_api_pack.insert_or_update_payment_detail(v_payment_id, v_payment_detail);
end;
/

-- �������� "�������� ������� �������"
declare 
    v_payment_id payment.payment_id%type := 83;
    v_delete_payment_detail t_number_array := t_number_array(1, 2, 3);
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
end;
/

-- �������� ����������� �� ����������� ����������. �������� �������� �������
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

-- �������� ����������� �� ����������� ����������. �������� ��������� �������
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

-- �������� ����������� �� ����������� ����������. �������� ��������� ������ �������
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

-- ���������� Unit-�����
-- �������� "�������� �������"
declare
    v_payment_detail t_payment_detail_array;
    v_payment_id payment.payment_id%type;
    v_summa payment.summa%type := 100;
    v_currency_id payment.currency_id%type := 840;
    v_from_client_id payment.from_client_id%type := 1;
    v_to_client_id payment.to_client_id%type := 1;
begin
    v_payment_id := payment_api_pack.create_payment(v_payment_detail, v_summa, v_currency_id, v_from_client_id, v_to_client_id);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception 
    when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������. �������� �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "����� �������"
declare 
    v_payment_id payment.payment_id%type;
    v_reason payment.status_change_reason%type := '������������ �������';
begin
    payment_api_pack.fail_payment(v_payment_id, v_reason);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������. ����� �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "������ �������"
declare 
    v_payment_id payment.payment_id%type := 83;
    v_reason payment.status_change_reason%type;
begin
    payment_api_pack.cancel_payment(v_payment_id, v_reason);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������. ������ �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "�������� ���������� �������"
declare 
    v_payment_id payment.payment_id%type;
begin
    payment_api_pack.successful_finish_payment(v_payment_id);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������. �������� ���������� �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "����������/���������� ������ �������"
declare 
    v_payment_id payment.payment_id%type;
    v_payment_detail t_payment_detail_array;   
begin
    payment_detail_api_pack.insert_or_update_payment_detail(v_payment_id, v_payment_detail);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������ �������. ����������/���������� ������ �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "�������� ������� �������" ����_1
declare 
    v_payment_id payment.payment_id%type;
    v_delete_payment_detail t_number_array := t_number_array(1, 2, 3);
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������ �������. �������� ������� �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "�������� ������� �������" ����_2
declare 
    v_payment_id payment.payment_id%type := 83;
    v_delete_payment_detail t_number_array := t_number_array();
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������ �������. �������� ������� �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- �������� "�������� ������� �������" ����_3
declare 
    v_payment_id payment.payment_id%type := 83;
    v_delete_payment_detail t_number_array;
begin
    payment_detail_api_pack.delete_payment_detail(v_payment_id, v_delete_payment_detail);
    raise_application_error(-20999, 'Unit ���� ��� API ��������� �� �����');
exception
     when common_pack.e_invalid_input_parameter then
        dbms_output.put_line('API ������ �������. �������� ������� �������. ���������� ���������� �������. ������: ' || sqlerrm);
end;
/

-- ���������� ����� (��������)
-- �������� ������� �������� payment ����� �� ����� API
declare
  v_payment_id payment.payment_id%type := 1000;
begin
  delete from payment p1 where p1.payment_id = v_payment_id;
  raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');  
exception
  when common_pack.e_delete_forbidden then
    dbms_output.put_line('�������� �������. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/

-- �������� ������� ������� � payment �� ����� API
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

  raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('������� � ������� payment �� ����� API. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/

-- �������� ������� ���������� � payment �� ����� API
declare
  v_payment_id   payment.payment_id%type := 1000;
begin
       update payment p
            set p.status = 2
            where payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');  
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('���������� ������� payment �� ����� API. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/

-- ������� �� ����� API - ������ �������
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
  
	raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');		
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('������� � ������� payment_detail �� ����� API. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/

-- ��������� �� ����� API (����������) - ������ �������
declare
  v_payment_id   payment_detail.payment_id%type := 1000;
begin
  update payment_detail p1
     set p1.field_value = p1.field_value
   where p1.payment_id = v_payment_id;
  
	raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');	 
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('���������� ������� payment_detail �� ����� API. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/

-- �������� �� ����� API (����������) - ������ �������
declare
  v_payment_id   payment_detail.payment_id%type := 1000;
begin
  delete payment_detail p1     
   where p1.payment_id = v_payment_id;
  
	raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');	 
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('�������� �� ������� payment_detail �� ����� API. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/

-- ���������� ���� �� ���������� �������
declare
  v_payment_id payment.payment_id%type := -777;
  v_reason    payment.status_change_reason%type := '�������� �������';
begin
  payment_api_pack.fail_payment(v_payment_id, v_reason);
  raise_application_error(-20999, 'Unit-���� ��� API ��������� �� �����');	 
exception
  when common_pack.e_object_notfound then 
    dbms_output.put_line('������ �� ������. ���������� ���������� �������. ������: '|| sqlerrm); 
end;
/