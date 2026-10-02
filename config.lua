-- Configure uma chave longa e aleatória antes de iniciar o resource.
Config = {}
Config.ApiKey = 'FIRETESTES123' -- Não compartilhe, caso compartilhada a pessoa poderá ter acesso a api do seu servidor e usar comandos dentro dele!

-- SetHttpHandler usa a porta TCP/HTTP do FXServer (endpoint_add_tcp no server.cfg).
-- Esta opção só documenta a porta esperada; ela não abre um listener separado.
Config.ApiPort = 30120 -- só mexer caso a porta do seu servidor for outra
Config.ApiHost = '127.0.0.1' -- ip da sua vps, caso estiver testando localmente deixe como 127.0.0.1 e lembre-se que  para funcionar localmente você deve abrir as portas 3306 e 30120 no seu moldem

Config.MaxBodyBytes = 4096 -- não mexer
Config.MaxCommandBytes = 512 -- não mexer
