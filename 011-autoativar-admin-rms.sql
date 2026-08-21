-- 011 | Ativação automática e segura do administrador RMS
-- Execute este arquivo inteiro no SQL Editor do Supabase.
-- A função somente consegue cadastrar a conta indicada abaixo ou manter um administrador já existente.

begin;

create or replace function public.activate_rms_portal_admin()
returns boolean
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  current_user_id uuid;
  current_email text;
  rms_admin_email constant text := 'raulmirandadesign@outlook.com';
begin
  current_user_id := auth.uid();
  current_email := lower(trim(coalesce(auth.jwt() ->> 'email', '')));

  if current_user_id is null then
    return false;
  end if;

  if current_email = rms_admin_email then
    insert into public.client_portal_admins (user_id)
    values (current_user_id)
    on conflict (user_id) do nothing;
  end if;

  return exists (
    select 1
    from public.client_portal_admins
    where user_id = current_user_id
  );
end;
$$;

revoke all on function public.activate_rms_portal_admin() from public, anon;
grant execute on function public.activate_rms_portal_admin() to authenticated;

commit;

-- Conferência opcional, para executar depois de entrar no Portal:
-- select public.activate_rms_portal_admin();
