-- ED Project: Retrospective Email Import (Gmail).
--
-- Separate, Gmail-specific pipeline from the existing Outlook-based
-- ed_project_messages/ed_project_files ingestion (20260921072000). This
-- feature lets an authorized user search and selectively import HISTORICAL
-- Gmail messages (body + attachments) from the mailbox already used for
-- pharmacy notifications (EMAIL_USER / GOOGLE_APP_PASSWORD via IMAP — no new
-- Gmail OAuth client was created; none existed to reuse, and the existing
-- App Password already grants IMAP read access to the same account).
--
-- The imported emails may reference the same kind of sensitive personal
-- health information as ed_patient_referrals (ED = erectile dysfunction
-- treatment referrals) under PDPA s.26, so access is gated by a dedicated,
-- narrow permission (manage_ed_email_import) rather than the broad
-- view_ed_project permission every role currently holds, and every write
-- happens only through SECURITY DEFINER functions / the service-role API
-- route — never direct table grants to authenticated.

create table if not exists public.ed_email_records (
  id uuid primary key default gen_random_uuid(),
  provider text not null default 'gmail',
  mailbox_address text not null,
  gmail_message_id text not null,
  gmail_thread_id text,
  sender text not null,
  recipients jsonb not null default '[]'::jsonb,
  cc jsonb not null default '[]'::jsonb,
  subject text,
  received_at timestamptz,
  sent_at timestamptz,
  body_plain text,
  body_html text,
  snippet text,
  headers jsonb not null default '{}'::jsonb,
  import_source text not null default 'retrospective_email',
  imported_at timestamptz not null default now(),
  imported_by uuid references pharmacy_access.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  search_vector tsvector generated always as (
    setweight(to_tsvector('simple', coalesce(subject, '')), 'A')
    || setweight(to_tsvector('simple', coalesce(sender, '')), 'B')
    || setweight(to_tsvector('simple', coalesce(body_plain, '')), 'C')
  ) stored,
  unique (mailbox_address, gmail_message_id)
);

create table if not exists public.ed_email_attachments (
  id uuid primary key default gen_random_uuid(),
  email_id uuid not null references public.ed_email_records(id) on delete cascade,
  gmail_attachment_ref text,
  original_filename text not null,
  mime_type text not null,
  file_size_bytes bigint not null default 0,
  storage_path text not null,
  sha256 text not null,
  file_category text not null default 'other'
    check (file_category in ('pdf', 'image', 'document', 'other')),
  extracted_text text,
  extraction_status text not null default 'pending'
    check (extraction_status in ('pending', 'success', 'failed', 'not_applicable')),
  created_at timestamptz not null default now(),
  unique (email_id, sha256)
);

create table if not exists public.ed_email_import_batches (
  id uuid primary key default gen_random_uuid(),
  triggered_by uuid references pharmacy_access.users(id),
  search_criteria jsonb not null default '{}'::jsonb,
  status text not null default 'running'
    check (status in ('running', 'success', 'partial', 'failed')),
  total_count integer not null default 0,
  processed_count integer not null default 0,
  imported_count integer not null default 0,
  skipped_count integer not null default 0,
  failed_count integer not null default 0,
  started_at timestamptz not null default now(),
  finished_at timestamptz
);

create table if not exists public.ed_email_import_audit (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid references public.ed_email_import_batches(id) on delete set null,
  user_id uuid references pharmacy_access.users(id),
  gmail_message_id text,
  action text not null check (action in ('success', 'skip', 'failure')),
  error_code text,
  resulting_email_record_id uuid references public.ed_email_records(id),
  created_at timestamptz not null default now()
);

create index if not exists ed_email_records_received_idx
  on public.ed_email_records(received_at desc);
create index if not exists ed_email_records_sender_idx
  on public.ed_email_records(sender);
create index if not exists ed_email_records_search_vector_idx
  on public.ed_email_records using gin (search_vector);
create index if not exists ed_email_attachments_email_idx
  on public.ed_email_attachments(email_id);
create index if not exists ed_email_attachments_category_idx
  on public.ed_email_attachments(file_category);
create index if not exists ed_email_import_audit_batch_idx
  on public.ed_email_import_audit(batch_id, created_at desc);

alter table public.ed_email_records enable row level security;
alter table public.ed_email_attachments enable row level security;
alter table public.ed_email_import_batches enable row level security;
alter table public.ed_email_import_audit enable row level security;

revoke all on public.ed_email_records from public, anon, authenticated;
revoke all on public.ed_email_attachments from public, anon, authenticated;
revoke all on public.ed_email_import_batches from public, anon, authenticated;
revoke all on public.ed_email_import_audit from public, anon, authenticated;
grant all on public.ed_email_records to service_role;
grant all on public.ed_email_attachments to service_role;
grant all on public.ed_email_import_batches to service_role;
grant all on public.ed_email_import_audit to service_role;

create or replace function pharmacy_access.has_permission(p_auth_user_id uuid, p_permission_key text)
returns boolean
language sql
stable
security definer
set search_path = pharmacy_access, public, auth
as $$
  select pharmacy_access.is_global_admin(p_auth_user_id)
    or exists (
      select 1
      from pharmacy_access.users u
      join pharmacy_access.role_permissions rp
        on rp.enabled = true
      where u.auth_user_id = p_auth_user_id
        and u.is_active = true
        and rp.permission_key = p_permission_key
        and (
          exists (
            select 1 from pharmacy_access.global_roles gr
            where gr.user_id = u.id and gr.active = true and gr.role = rp.role
          )
          or exists (
            select 1 from pharmacy_access.branch_roles br
            where br.user_id = u.id and br.active = true and br.role = rp.role
          )
        )
    );
$$;

insert into pharmacy_access.role_permissions(role, permission_key, enabled)
values
  ('admin', 'manage_ed_email_import', true),
  ('area_manager', 'manage_ed_email_import', false),
  ('manager', 'manage_ed_email_import', false),
  ('rx', 'manage_ed_email_import', false),
  ('staff', 'manage_ed_email_import', false)
on conflict (role, permission_key) do nothing;

-- Functions-only access (no RLS SELECT policy, same convention as
-- ed_patient_referrals — deliberately stricter than the Outlook
-- ed_project_* tables since this handles the same class of sensitive data).
-- Every function re-checks manage_ed_email_import itself; writes happen only
-- via service_role from the API route.

create or replace function public.ed_check_imported(p_gmail_message_ids text[])
returns table (gmail_message_id text, imported boolean, imported_at timestamptz, email_record_id uuid)
language plpgsql
stable
security definer
set search_path = public, pharmacy_access, auth
as $$
begin
  if not pharmacy_access.has_permission(auth.uid(), 'manage_ed_email_import') then
    raise exception 'PHARMACY_PERMISSION_REQUIRED';
  end if;

  return query
    select ids.gmail_message_id,
           (r.id is not null) as imported,
           r.imported_at,
           r.id as email_record_id
    from unnest(p_gmail_message_ids) as ids(gmail_message_id)
    left join public.ed_email_records r
      on r.gmail_message_id = ids.gmail_message_id;
end;
$$;

create or replace function public.ed_list_imported_emails(
  p_search text default null,
  p_date_from timestamptz default null,
  p_date_to timestamptz default null,
  p_sender text default null,
  p_has_attachment boolean default null,
  p_file_category text default null,
  p_limit int default 50,
  p_before timestamptz default null
)
returns table (
  id uuid,
  gmail_message_id text,
  gmail_thread_id text,
  sender text,
  recipients jsonb,
  subject text,
  snippet text,
  received_at timestamptz,
  attachment_count bigint,
  imported_at timestamptz,
  imported_by_name text
)
language plpgsql
stable
security definer
set search_path = public, pharmacy_access, auth
as $$
begin
  if not pharmacy_access.has_permission(auth.uid(), 'manage_ed_email_import') then
    raise exception 'PHARMACY_PERMISSION_REQUIRED';
  end if;

  return query
    select r.id, r.gmail_message_id, r.gmail_thread_id, r.sender, r.recipients,
           r.subject, r.snippet, r.received_at,
           count(a.id) as attachment_count,
           r.imported_at,
           u.full_name as imported_by_name
    from public.ed_email_records r
    left join public.ed_email_attachments a on a.email_id = r.id
    left join pharmacy_access.users u on u.id = r.imported_by
    where (p_search is null or r.search_vector @@ plainto_tsquery('simple', p_search))
      and (p_date_from is null or r.received_at >= p_date_from)
      and (p_date_to is null or r.received_at <= p_date_to)
      and (p_sender is null or r.sender ilike '%' || p_sender || '%')
      and (p_before is null or r.received_at < p_before)
    group by r.id, u.full_name
    having (p_has_attachment is null or (p_has_attachment = (count(a.id) > 0)))
       and (p_file_category is null or bool_or(a.file_category = p_file_category))
    order by r.received_at desc nulls last
    limit greatest(1, least(p_limit, 200));
end;
$$;

create or replace function public.ed_get_imported_email(p_email_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pharmacy_access, auth
as $$
declare
  v_result jsonb;
begin
  if not pharmacy_access.has_permission(auth.uid(), 'manage_ed_email_import') then
    raise exception 'PHARMACY_PERMISSION_REQUIRED';
  end if;

  select jsonb_build_object(
    'email', to_jsonb(r) - 'search_vector',
    'attachments', coalesce(
      (select jsonb_agg(to_jsonb(a) order by a.created_at)
       from public.ed_email_attachments a
       where a.email_id = r.id),
      '[]'::jsonb
    )
  )
  into v_result
  from public.ed_email_records r
  where r.id = p_email_id;

  if v_result is null then
    raise exception 'ED_EMAIL_NOT_FOUND';
  end if;

  return v_result;
end;
$$;

create or replace function public.ed_list_import_batches(p_limit int default 50)
returns setof public.ed_email_import_batches
language plpgsql
stable
security definer
set search_path = public, pharmacy_access, auth
as $$
begin
  if not pharmacy_access.has_permission(auth.uid(), 'manage_ed_email_import') then
    raise exception 'PHARMACY_PERMISSION_REQUIRED';
  end if;

  return query
    select * from public.ed_email_import_batches
    order by started_at desc
    limit greatest(1, least(p_limit, 200));
end;
$$;

create or replace function public.ed_get_import_batch_detail(p_batch_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pharmacy_access, auth
as $$
declare
  v_result jsonb;
begin
  if not pharmacy_access.has_permission(auth.uid(), 'manage_ed_email_import') then
    raise exception 'PHARMACY_PERMISSION_REQUIRED';
  end if;

  select jsonb_build_object(
    'batch', to_jsonb(b),
    'audit', coalesce(
      (select jsonb_agg(to_jsonb(a) order by a.created_at)
       from public.ed_email_import_audit a
       where a.batch_id = b.id),
      '[]'::jsonb
    )
  )
  into v_result
  from public.ed_email_import_batches b
  where b.id = p_batch_id;

  if v_result is null then
    raise exception 'ED_EMAIL_BATCH_NOT_FOUND';
  end if;

  return v_result;
end;
$$;

grant execute on function public.ed_check_imported(text[]) to authenticated;
grant execute on function public.ed_list_imported_emails(text, timestamptz, timestamptz, text, boolean, text, int, timestamptz) to authenticated;
grant execute on function public.ed_get_imported_email(uuid) to authenticated;
grant execute on function public.ed_list_import_batches(int) to authenticated;
grant execute on function public.ed_get_import_batch_detail(uuid) to authenticated;

insert into storage.buckets (id, name, public)
values ('ed-email-import-attachments', 'ed-email-import-attachments', false)
on conflict (id) do update set public = false;

-- Object keys written as <email_record_uuid>/<sha256>-<original_filename>.
-- Signed-URL reads only, gated by the same permission (no RLS SELECT policy
-- needed on storage.objects since every read goes through a server route
-- that calls supabase.storage.createSignedUrl with the service role after
-- checking manage_ed_email_import itself — matches how attachments for
-- ed_patient_referrals are intended to be served, since that table has no
-- direct client read path either).
