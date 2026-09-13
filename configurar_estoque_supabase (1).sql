-- Mimar · Controle de Estoque público para consulta e atualização
create table if not exists public.estoque_controle (
  id uuid primary key default gen_random_uuid(),
  produto text not null,
  quantidade integer not null default 0 check (quantidade >= 0),
  volume text not null default 'unidade' check (volume in ('unidade','fardo','caixa_master')),
  urgencia text not null default 'normal' check (urgencia in ('normal','atencao','emergencia')),
  atualizado_em timestamptz not null default now()
);

alter table public.estoque_controle add column if not exists volume text not null default 'unidade';

create index if not exists estoque_controle_produto_idx on public.estoque_controle (produto);
create index if not exists estoque_controle_urgencia_idx on public.estoque_controle (urgencia);
alter table public.estoque_controle enable row level security;

-- Remove políticas antigas desta tabela.
drop policy if exists "estoque_admin_select" on public.estoque_controle;
drop policy if exists "estoque_admin_insert" on public.estoque_controle;
drop policy if exists "estoque_admin_update" on public.estoque_controle;
drop policy if exists "estoque_admin_delete" on public.estoque_controle;
drop policy if exists "estoque_public_select" on public.estoque_controle;
drop policy if exists "estoque_public_insert" on public.estoque_controle;
drop policy if exists "estoque_public_update" on public.estoque_controle;

-- Qualquer visitante do painel pode consultar, cadastrar e atualizar estoque.
create policy "estoque_public_select" on public.estoque_controle for select to anon, authenticated using (true);
create policy "estoque_public_insert" on public.estoque_controle for insert to anon, authenticated with check (true);
create policy "estoque_public_update" on public.estoque_controle for update to anon, authenticated using (true) with check (true);

-- Exclusão continua reservada ao administrador, evitando apagar produtos por engano.
create policy "estoque_admin_delete" on public.estoque_controle for delete to authenticated using (public.is_admin());
