create or replace trigger paymnet_data_b_iud_api
  before insert or update or delete on payment_detail
begin
  payment_detail_api_pack.is_changes_through_api(); -- проверяем выполняется ли изменение через API
end;
