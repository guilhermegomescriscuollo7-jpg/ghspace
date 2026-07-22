-- ============================================================
--  GH Space Tech — Schema do banco de dados (Supabase / Postgres)
--  Rode este arquivo no Supabase:  SQL Editor > New query > Run
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- 1) LEADS  — pedidos de contato / orçamento vindos do site
-- ------------------------------------------------------------
create table if not exists public.leads (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  name           text not null check (char_length(name) between 2 and 120),
  phone          text check (char_length(phone) <= 40),
  email          text check (char_length(email) <= 160),
  service        text check (char_length(service) <= 120),
  prefer_contact text check (char_length(prefer_contact) <= 40),
  street         text check (char_length(street) <= 160),
  addr_number    text check (char_length(addr_number) <= 20),
  district       text check (char_length(district) <= 120),
  city           text check (char_length(city) <= 120),
  message        text check (char_length(message) <= 3000),
  consent        boolean not null default false,
  status         text not null default 'novo'
                 check (status in ('novo','em_contato','concluido','descartado')),
  source         text default 'site'
);

-- Se a tabela já existir de uma instalação anterior, garante as novas colunas:
alter table public.leads add column if not exists prefer_contact text;
alter table public.leads add column if not exists street         text;
alter table public.leads add column if not exists addr_number    text;
alter table public.leads add column if not exists district       text;
alter table public.leads add column if not exists city           text;
alter table public.leads add column if not exists consent        boolean not null default false;
create index if not exists leads_created_idx on public.leads (created_at desc);

-- ------------------------------------------------------------
-- 2) PROJECTS  — portfólio (sites/sistemas entregues)
-- ------------------------------------------------------------
create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  name        text not null,
  kind        text,                 -- ex.: 'Poder Legislativo'
  url         text,                 -- link do site
  site_label  text,                 -- texto exibido (ex.: 'doresopolis.mg.leg.br')
  badge       text,                 -- iniciais (ex.: 'CD') — usado se não houver logo
  logo_url    text,                 -- caminho/URL da logo (ex.: 'assets/logos/camara.png')
  accent      text default 'pref',  -- 'camara' | 'santa' | 'pref' ou um hex (#2f6f9e)
  sort        int  not null default 0,
  published   boolean not null default true
);

-- ------------------------------------------------------------
-- 3) TESTIMONIALS  — depoimentos de clientes
-- ------------------------------------------------------------
create table if not exists public.testimonials (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  author      text not null,
  role        text,                 -- cargo / instituição
  quote       text not null,
  rating      int check (rating between 1 and 5),
  approved    boolean not null default false,  -- só aparece no site quando true
  sort        int not null default 0
);

-- ------------------------------------------------------------
-- 4) SERVICES  — serviços e preços
-- ------------------------------------------------------------
create table if not exists public.services (
  id           uuid primary key default gen_random_uuid(),
  created_at   timestamptz not null default now(),
  title        text not null,
  description  text,
  tags         text[] default '{}',
  price_from   numeric,             -- valor inicial (opcional)
  price_label  text,                -- ex.: 'a partir de'
  icon         text default 'wrench', -- 'site' | 'code' | 'support' | 'wrench'
  sort         int not null default 0,
  active       boolean not null default true
);

-- ============================================================
--  ROW LEVEL SECURITY
-- ============================================================
alter table public.leads        enable row level security;
alter table public.projects     enable row level security;
alter table public.testimonials enable row level security;
alter table public.services     enable row level security;

-- LEADS: qualquer visitante pode INSERIR; ninguém lê pela chave pública
-- (a leitura acontece só no painel do Supabase / service_role).
drop policy if exists leads_insert_public on public.leads;
create policy leads_insert_public on public.leads
  for insert to anon, authenticated
  with check (true);

-- PROJECTS: leitura pública apenas dos publicados
drop policy if exists projects_read_public on public.projects;
create policy projects_read_public on public.projects
  for select to anon, authenticated
  using (published = true);

-- TESTIMONIALS: leitura pública apenas dos aprovados
drop policy if exists testimonials_read_public on public.testimonials;
create policy testimonials_read_public on public.testimonials
  for select to anon, authenticated
  using (approved = true);

-- SERVICES: leitura pública apenas dos ativos
drop policy if exists services_read_public on public.services;
create policy services_read_public on public.services
  for select to anon, authenticated
  using (active = true);

-- ============================================================
--  DADOS INICIAIS (seed) — projetos e serviços reais do site
--  (Depoimentos NÃO são semeados: cadastre os reais no painel.)
-- ============================================================
insert into public.projects (name, kind, url, site_label, badge, logo_url, accent, sort) values
  ('Câmara Municipal de Doresópolis', 'Poder Legislativo', 'https://www.doresopolis.mg.leg.br/', 'doresopolis.mg.leg.br', 'CD', 'assets/logos/camara.png', 'camara', 1),
  ('Santa Casa de Misericórdia — Piumhi', 'Saúde', 'https://www.santacasapiumhi.com.br/', 'santacasapiumhi.com.br', 'SC', 'assets/logos/santacasa.png', 'santa', 2),
  ('Prefeitura Municipal de Doresópolis', 'Poder Executivo', 'https://www.doresopolis.mg.gov.br/', 'Doresópolis · Um Novo Tempo', 'PD', 'assets/logos/prefeitura.png', 'pref', 3)
on conflict do nothing;

insert into public.services (title, description, tags, icon, sort) values
  ('Criação de Sites', 'Sites institucionais rápidos, responsivos e otimizados — do portal público ao site da sua empresa.', array['Institucional','Responsivo','SEO'], 'site', 1),
  ('Sistemas sob Medida', 'Desenvolvimento de sistemas e aplicações que resolvem o problema real do seu dia a dia.', array['Web','Automação','Painéis'], 'code', 2),
  ('Suporte & Infraestrutura', 'Consultoria de informática, redes e configurações, com atendimento ágil.', array['Consultoria','Redes','Configuração'], 'support', 3),
  ('Manutenção de PCs & Notebooks', 'Formatação, limpeza física e de software, instalação de programas e ajuste das configurações.', array['Formatação','Limpeza','Instalação de programas','Configurações'], 'wrench', 4)
on conflict do nothing;
