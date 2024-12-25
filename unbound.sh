#!/bin/bash

# Atualizando o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalando o Unbound
echo "Instalando o Unbound..."
sudo apt install -y unbound

# Desativando permanentemente o systemd-resolved (caso esteja ativo)
echo "Desativando o systemd-resolved..."

# Parar o serviço do systemd-resolved
sudo systemctl stop systemd-resolved

# Desabilitar o serviço para não iniciar na inicialização
sudo systemctl disable systemd-resolved

# Remover o link simbólico do resolved.conf
sudo rm /etc/resolv.conf

# Criar um novo link simbólico para o resolv.conf do Unbound
sudo ln -s /etc/resolvconf/run/resolv.conf /etc/resolv.conf

# Configuração do Unbound
echo "Configurando o Unbound..."

# Criar arquivo de configuração com as opções fornecidas
cat <<EOF | sudo tee /etc/unbound/unbound.conf
server:
    # Diretório de trabalho onde o Unbound procura seus arquivos de configuração
    directory: "/etc/unbound"

    # Executar como usuário unbound para garantir segurança
    username: unbound

    # Nível de verbosidade para logs (quanto maior o número, mais detalhes serão registrados)
    verbosity: 2

    # Interfaces de escuta (0.0.0.0 permite que o Unbound escute em todas as interfaces IPv4)
    interface: 0.0.0.0
    # interface: ::0 # Se você usar IPv6, descomente essa linha para habilitar a escuta no IPv6

    # Porta de escuta para o Unbound (por padrão, é 53)
    port: 53

    # Prefetching de entradas de cache quase expiradas (isso acelera a resolução de nomes já acessados recentemente)
    prefetch: yes

    # Controle de acesso: define os IPs ou sub-redes que têm permissão para acessar o serviço DNS
    access-control: 192.168.10.0/24 allow  # Rede interna
    access-control: 127.0.0.1/24 allow    # Acesso local

    # Ocultar informações do servidor dos clientes (evita que o servidor revele sua identidade e versão)
    hide-identity: yes
    hide-version: yes

    # Nome dos servidores locais, mapeando domínios internos para endereços IP
    local-data: "chatbot.local A 192.168.10.100"
    local-data: "typebot.local A 192.168.10.100"
    local-data: "portainer.local A 192.168.10.100"
    local-data: "minio.local A 192.168.10.100"
    local-data: "minios3.local A 192.168.10.100"
    local-data: "evolution.local A 192.168.10.100"
    local-data: "chatwoot.local A 192.168.10.100"
    local-data: "n8n.local A 192.168.10.100"
    local-data: "mongodb.local A 192.168.10.100"

    # Parâmetros adicionais para melhorar o desempenho e segurança

    # Define o tempo máximo de vida (TTL) em cache de registros DNS
    cache-max-ttl: 14400  # 4 horas

    # Define o tempo mínimo de vida (TTL) em cache de registros DNS
    cache-min-ttl: 11000  # 3 horas e 3 minutos

    # Permite ao Unbound usar respostas negativas (NSEC/NSEC3) de forma agressiva
    aggressive-nsec: yes

    # Esconde o identificador do servidor
    hide-identity: yes

    # Esconde a versão do Unbound
    hide-version: yes

    # Usa variações de maiúsculas e minúsculas no campo QNAME para mitigar ataques de envenenamento de cache
    use-caps-for-id: yes

    # Define o número de threads que o Unbound usará para processar consultas DNS
    num-threads: 4

    # Divide o cache de mensagens DNS em 8 segmentos
    msg-cache-slabs: 8

    # Divide o cache de registros de recursos (RRsets) em 8 segmentos
    rrset-cache-slabs: 8

    # Segmenta o cache de informações de infraestrutura em 8 partes
    infra-cache-slabs: 8

    # Aloca até 256 MB para o cache de registros de recursos (RRsets)
    rrset-cache-size: 256m

    # Aloca até 128 MB para o cache de mensagens DNS
    msg-cache-size: 128m

    # Define o tamanho do buffer de recepção de soquetes em 8 MB
    so-rcvbuf: 8m

remote-control:
    # Permite o controle remoto do Unbound
    control-enable: no  # Desabilitado para maior segurança
    control-interface: 127.0.0.1  # Interface local para controle remoto (somente local)
    control-interface: ::1  # Habilitado para IPv6
    control-port: 8953  # Porta para a interface de controle remoto
EOF

# Definir permissões corretas para o arquivo de configuração
sudo chown unbound:unbound /etc/unbound/unbound.conf

# Habilitar o serviço Unbound para inicialização automática
echo "Habilitando o Unbound para inicialização automática..."
sudo systemctl enable unbound

# Reiniciar o Unbound para aplicar as configurações
echo "Reiniciando o Unbound..."
sudo systemctl restart unbound

# Verificar o status do serviço
echo "Verificando o status do Unbound..."
sudo systemctl status unbound | grep "Active"

# Verificar a configuração do Unbound
echo "Verificando a configuração do Unbound..."
sudo unbound-checkconf

echo "Instalação e configuração do Unbound concluídas com sucesso!"

