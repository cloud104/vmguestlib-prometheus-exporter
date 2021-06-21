# vmguestlib-prometheus-exporter

Este _wrapper_ utiliza a lib [vmguestlib](https://github.com/cloud104/vmguestlib) para exportar métricas que VMWare-tools exporta para o VCenter.

## Métricas Exportadas

|Metrica|Tipo|Descrição|
|---|---|---|
|vmware_vm_processor_time|Gauge|VM Processor time in percent|
|vmware_vm_processor_stolen_time|Gauge|VM Percent of Stolen CPU time|
|vmware_vm_processor_effective_speed|Gauge|VM Qty of MHz this vm is using|
|vmware_host_processor_speed|Gauge|Host processor speed in MHz|
|vmware_vm_processor_limit|Gauge|VM Processor Limit|
|vmware_vm_processor_reservation|Gauge|VM Processor Reservation in MHz|
|vmware_vm_processor_shares|Gauge|VM Processor Shares|
|vmware_vm_memory_active|Gauge|VM Memory used at this moment in MB|
|vmware_vm_ballooned|Gauge|VM Size of Balloon in MB|
|vmware_vm_memory_shared|Gauge|VM Shared Memory in MB|
|vmware_vm_memory_shared_saved|Gauge|VM Shared Memory Saved in MB|
|vmware_vm_memory_swapped|Gauge|VM Size of Swap|
|vmware_vm_memory_target_size|Gauge|VM Memory Target Size|
|vmware_vm_memory_used|Gauge|VM Memory real consumption in MB|
|vmware_vm_memory_limit|Gauge|VM Memory Limit defined in Vcenter in MB|
|vmware_vm_memory_reservation|Gauge|VM Reserved Memory for this VM in MB|
|vmware_vm_memory_shares|Gauge|VM Memory Share in same host|
|vmware_vm_memory_mapped|Gauge|VM Mapped Memory|

Para o entendimento completo das métricas, recomendo a leitura do guia de Resource Management da VMWare no [link](https://docs.vmware.com/en/VMware-vSphere/6.7/vsphere-esxi-vcenter-server-672-resource-management-guide.pdf)

### Métricas convertidas para percentagem

Algumas métricas foram convertidas para percentagem para facilitar a sua manipulação.

As métricas convertidas foram:

- vmware_vm_processor_stolen_time
- vmware_vm_processor_effective_speed
- vmware_vm_processor_time

Os valores são arredondados pela função nativa [round](https://docs.python.org/3/library/functions.html#round) do Python.

## Desenvolvimento
Em seu ambiente de desenvolvimento, utilize [virtualenv](https://docs.python.org/pt-br/3/library/venv.html);
- Instalar a lib do prometheus_client via pip `pip install prometheus-client`
- Instalar a lib do vmguestlib, para instalar no seu venv, siga os passos:
  - baixar o código-fonte da lib do git: https://github.com/cloud104/vmguestlib em um diretório diferente do exporter;
  - com o venv do exporter ativado, execute o comando no diretório do `vmguestlib`: `python3 setup.py install`
- [bumpversion](https://pypi.org/project/bumpversion/) para o controle de versão
- gnu make  

#### Geração dos pacotes
Os pacotes debian são gerados localmente, não há CI para esse projeto, pois o seu fluxo de desenvolvimento é bem baixo.

Como funciona a geração de pacotes:
- É criado um container local. Nesse container(debian) há todas as ferramentas e dependencias necessárias para se gerar o pacote debian;
- Todo o source desse projeto é montado dentro desse “container de build”;
- o comando para criar o deb é executado;
- o artefato gerado é deixado no diretório `dist`
- Após a geração, o pacote é copiado para o bucket `opscenter-isos/deb` na conta `totvs-kubernetes-service` do GCP (você precisa de acesso nessa conta, e o `gcloud` precisa estar configurado previamente)

Utilizamos `semantic version` nesse projeto. Para disparar um novo build utilize:

| Make Option | Action |
| --- | --- |
| patch | Gera um patch na versão (X.Y. **Z**). |
| minor | Gera uma versão minor (X. **Y**. Z). |
| major | Gera uma versão major (**X**. Y.Z). |

## Deploy nas VM's
O script necessita rodar diretamente na máquina virtual;
Ele inicia um servidor na porta 9242 em todas as _interfaces_ de rede;

### Pacotes necessários que devem ser instalados no servidor:
- Python versão > 3.3;
- Lib do Prometheus Client, em sistemas Ubuntu, o pacote chama-se `python3-prometheus-client`
- Lib do vmguestlib, essa lib, foi empacotada para simplificar a instalação em sistemas ubuntu. Veja mais informações nesse [repo](https://github.com/cloud104/vmguestlib).

O pacote entrega um `systemd service` chamado `vmguest-prom-exporter`, que é ativado quando o pacote é instalado pela primeira vez.

## Prometheus Operator
Para obter as metricas via prometheus operator, o [ServiceMonitor](prometheus-operator/servicemonitor.yaml) deve ser criado.

Os endpoints para monitoria necessitam ser criados. Como no cluster há o prometheus node-exporter, iremos pegar uma "carona" no daemonset que é instalado. Veja [aqui](prometheus-operator/service.yaml) como isso é feito. 

## Dashboards no grafana
O json com o conteúdo do dashboard está [aqui](grafana-dashboard)

Para o funcionamento correto do dashboard, o job no prometheus deve chamar-se "vmware-exporter".