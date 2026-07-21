# GH Space Tech — Site institucional

Site de página única da **GH Space Tech**, empresa de tecnologia de Doresópolis/Piumhi (MG):
criação de sites, desenvolvimento de sistemas, suporte de TI e manutenção de computadores e notebooks.

## Recursos
- Design escuro cinematográfico com animações dirigidas pelo scroll (notebook e gabinete que abrem ao rolar).
- Tema claro/escuro, layout responsivo e acessível (respeita `prefers-reduced-motion`).
- Portfólio com projetos reais e seção de contato (WhatsApp e e-mail).

## Como usar
Abra o arquivo [`index.html`](index.html) em qualquer navegador — é totalmente autocontido (sem dependências externas).

### Publicar com GitHub Pages
1. Repositório → **Settings** → **Pages**
2. Em *Source*, selecione a branch `main` e a pasta `/root`
3. O site ficará disponível em `https://guilhermegomescriscuollo7-jpg.github.io/ghspace/`

## Banco de dados (Supabase)

O site integra com o [Supabase](https://supabase.com) para:
- **Leads** — o formulário de contato/orçamento grava os pedidos no banco;
- **Projetos**, **Serviços** e **Depoimentos** — conteúdo carregado dinamicamente (com fallback para o conteúdo estático).

### Como configurar
1. Crie um projeto grátis em [supabase.com](https://supabase.com).
2. No painel, abra **SQL Editor → New query**, cole o conteúdo de [`supabase/schema.sql`](supabase/schema.sql) e clique em **Run**. Isso cria as tabelas, as políticas de segurança (RLS) e os dados iniciais.
3. Em **Project Settings → API**, copie a **Project URL** e a **anon public key**.
4. No [`index.html`](index.html), preencha o bloco de configuração:
   ```html
   <script>
     window.GH_SUPABASE = {
       url: "https://SEU-PROJETO.supabase.co",
       anonKey: "eyJhbGci..."
     };
   </script>
   ```
5. Faça commit/deploy. Pronto — o formulário passa a salvar em `leads` e o conteúdo vem do banco.

> A `anon key` é pública e segura de expor: o acesso é limitado pelas políticas de RLS
> (o público só pode **inserir** leads e **ler** o que está publicado/aprovado/ativo).

### Ver e gerenciar os dados
No painel do Supabase, em **Table Editor**, você acompanha os leads recebidos e edita
projetos, serviços e depoimentos sem mexer no código.

## Contato
- 📱 WhatsApp/Telefone: (37) 98845-5469
- ✉️ E-mail: ghspacetech@gmail.com
- 📍 Doresópolis · Piumhi — MG
