#!/bin/sh
# =====================================================================
# Provisiona o Metabase pela API, para o aluno não passar pelo
# assistente de tela nem cadastrar a conexão do Postgres à mão.
#
# É o mesmo caminho que a role Ansible da VM da disciplina usa: na
# edição open source do Metabase, conta de admin e bancos só entram por
# HTTP — não há arquivo de configuração para isso.
#
# Roda uma vez e sai. É idempotente: se o assistente já foi concluído
# ou o banco já está cadastrado, não duplica nada.
#
# Sobre a senha do admin: o Metabase recusa senha "comum" e exige ao
# menos um dígito (complexidade "normal"). "senac" e "senac-cubo" são
# rejeitadas com HTTP 400; por isso a senha da turma tem o ano no fim.
# =====================================================================
set -eu

MB="${MB_URL:-http://metabase:3000}"

# --- 1) esperar o Metabase responder -------------------------------
# A JVM sobe e migra o banco interno: passa de um minuto na primeira vez.
echo "Esperando o Metabase em ${MB} ..."
i=0
until curl -sf "${MB}/api/session/properties" > /tmp/props.json 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 90 ]; then
        echo "ERRO: o Metabase não respondeu em ${MB} depois de 7 minutos." >&2
        echo "Veja os logs com: docker compose logs metabase" >&2
        echo "Causa comum: pouca memória — o Metabase pede uns 2 GB livres." >&2
        exit 1
    fi
    sleep 5
done
echo "Metabase respondeu."

# --- 2) criar a conta de admin ------------------------------------
# O setup-token só vem preenchido enquanto o assistente não foi concluído;
# o próprio Metabase o apaga ao criar o primeiro usuário. Depois vem null.
TOKEN=$(sed -n 's/.*"setup-token":"\([^"]*\)".*/\1/p' /tmp/props.json)

if [ -n "${TOKEN}" ]; then
    echo "Criando a conta de administrador ${MB_ADMIN_EMAIL} ..."
    curl -sf -X POST "${MB}/api/setup" \
        -H 'Content-Type: application/json' \
        -d "{
              \"token\": \"${TOKEN}\",
              \"user\": {
                \"first_name\": \"${MB_ADMIN_NOME}\",
                \"last_name\": \"${MB_ADMIN_SOBRENOME}\",
                \"email\": \"${MB_ADMIN_EMAIL}\",
                \"password\": \"${MB_ADMIN_SENHA}\"
              },
              \"prefs\": {
                \"site_name\": \"${MB_SITE_NOME}\",
                \"allow_tracking\": false
              }
            }" > /dev/null
    echo "Conta criada."
else
    echo "O assistente já foi concluído antes; seguindo para o login."
fi

# --- 3) abrir sessão ----------------------------------------------
SESSAO=$(curl -sf -X POST "${MB}/api/session" \
    -H 'Content-Type: application/json' \
    -d "{\"username\": \"${MB_ADMIN_EMAIL}\", \"password\": \"${MB_ADMIN_SENHA}\"}" \
    | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

if [ -z "${SESSAO}" ]; then
    echo "ERRO: o Metabase recusou o login ${MB_ADMIN_EMAIL}." >&2
    echo "Isso acontece se o assistente foi concluído à mão com outra conta." >&2
    echo "Para recomeçar do zero: docker compose down -v && docker compose up" >&2
    exit 1
fi

# --- 4) cadastrar o Postgres --------------------------------------
# O POST não é idempotente: repetido, cadastra o mesmo banco várias vezes.
# Por isso conferimos a lista antes.
if curl -sf "${MB}/api/database" -H "X-Metabase-Session: ${SESSAO}" \
    | grep -q "\"name\":\"${MB_BANCO_NOME}\""; then
    echo "O banco \"${MB_BANCO_NOME}\" já está cadastrado."
else
    echo "Cadastrando o Postgres como \"${MB_BANCO_NOME}\" ..."
    curl -sf -X POST "${MB}/api/database" \
        -H 'Content-Type: application/json' \
        -H "X-Metabase-Session: ${SESSAO}" \
        -d "{
              \"engine\": \"postgres\",
              \"name\": \"${MB_BANCO_NOME}\",
              \"details\": {
                \"host\": \"postgres\",
                \"port\": 5432,
                \"dbname\": \"${POSTGRES_DB}\",
                \"user\": \"${POSTGRES_USER}\",
                \"password\": \"${POSTGRES_PASSWORD}\",
                \"ssl\": false,
                \"tunnel-enabled\": false
              }
            }" > /dev/null
    echo "Banco cadastrado."
fi

echo ""
echo "======================================================"
echo " Metabase pronto em http://localhost:${MB_PORTA_HOST}"
echo " Login: ${MB_ADMIN_EMAIL}"
echo " Senha: ${MB_ADMIN_SENHA}"
echo "======================================================"
