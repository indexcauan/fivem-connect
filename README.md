# fivem-connect

Resource independente de framework que recebe requisições HTTP autenticadas no FXServer e encaminha um comando para o cliente de um jogador.

## Instalação

1. Copie esta pasta para `resources/[local]/fivem-connect`.
2. Edite `config.lua` e defina `Config.ApiKey` com uma chave longa e aleatória.
3. No `server.cfg`, configure a porta TCP/HTTP do FXServer e inicie o resource:

   ```cfg
   endpoint_add_tcp "0.0.0.0:30120"
   ensure fivem-connect
   ```

   Se já existe `endpoint_add_tcp`, mantenha o endpoint existente; não adicione uma linha duplicada. `SetHttpHandler` usa o listener TCP do FXServer, então `Config.ApiPort` não abre uma porta própria. Libere TCP 30120 no firewall e faça o encaminhamento da porta na VPS/roteador para acesso externo. UDP não atende requisições HTTP.

## API

O `SetHttpHandler` encaminha a URL pelo nome do resource. Para este projeto, teste `GET http://127.0.0.1:30120/fivem-connect/health`. A raiz `/` não é a rota de saúde. Se a pasta/resource tiver outro nome ou o endpoint TCP usar outra porta, ajuste os valores correspondentes.

Envie `POST http://SEU_IP:30120/fivem-connect/execute` com os headers `Content-Type: application/json` e `X-API-Key: SUA_CHAVE`, e o corpo:

```json
{
  "playerId": 12,
  "command": "comando_de_console argumento"
}
```

Resposta `202` significa que o FXServer encaminhou o evento ao cliente; não confirma que o comando existe ou teve efeito. O jogador precisa estar conectado.

## Bot Discord (`/god`, `/fix` e `/car`)

O bot em `discord-bot/` encaminha comandos ao jogador indicado e responde no canal com o status HTTP da API.

1. Crie um bot no [Discord Developer Portal](https://discord.com/developers/applications) e convide-o com os escopos `bot` e `applications.commands`.
2. Em `discord-bot/`, rode `npm install` e copie `.env.example` para `.env`.
3. Configure `DISCORD_TOKEN`, `DISCORD_CLIENT_ID`, `FIVEM_API_URL` (somente a origem, por exemplo `http://127.0.0.1:30120`) e `FIVEM_API_KEY` (igual à chave em `config.lua`). `FIVEM_RESOURCE_NAME` é opcional; o padrão é `fivem-connect` e deve corresponder ao nome da pasta/resource no FXServer. `DISCORD_GUILD_ID` é opcional e agiliza o registro durante testes.
4. Rode `npm run deploy-commands` e depois `npm start`.
5. Após qualquer alteração dos comandos, rode `npm run deploy-commands` e depois `npm start`.

Uso no Discord:

- `/god id: 12` encaminha `god 12` ao jogador.
- `/fix id: 12` conserta o veículo em que o jogador está ou o mais próximo, em um raio de 8 metros.
- `/car id: 12 modelo: adder` cria o veículo `adder` à frente do jogador. `modelo` é o spawn name do veículo.

Opcionalmente, informe IDs Discord separados por vírgulas em `ALLOWED_USER_IDS` para restringir o uso. Uma resposta positiva no Discord confirma o encaminhamento, não o resultado do comando no jogo. Mantenha `.env` e as chaves privadas.

## Limites

- Não depende de ESX, QBCore ou outro framework; o comando informado precisa existir e estar disponível no cliente.
- `ExecuteCommand` executa a linha no runtime cliente, equivalente a um comando do F8; não abre a interface visual do console.
- O resource não fornece TLS. Para exposição pública, restrinja a origem via firewall ou use um proxy HTTPS privado.
