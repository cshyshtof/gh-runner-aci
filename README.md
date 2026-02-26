# GitHub Actions Runner / Ansible ACI

## Wstęp

Projekt ten definiuje bezpieczne i odizolowane środowisko kontenerowe dla automatyzacji Cisco ACI, przy użyciu GitHub Actions Self-hosted Runner.

Rozwiązanie to wykorzystuje model Containerized Job. Proces GitHub Runner działa bezpośrednio na systemie (Alma Linux), natomiast każde zadanie automatyzacji wykonywane jest wewnątrz dedykowanego kontenera Docker.

Kluczowe korzyści:

- Izolacja: brak konfliktów bibliotek (python, kolekcje ansible)
- Powtarzalność: każde uruchomienie CI/CD korzysta z identycznego obrazu
- Bezpieczeństwo: procesy Ansible działają na uprawnieniach nieuprzywilejowanego użytkownika

Wymagania wstępne

- System: Alma Linux (lub inny kompatybilny z RHEL)
- Docker: zainstalowany lokalnie i działający jako proces (`systemctl status docker`)
- Uprawnienia: użytkownik systemowy runnera musi być w grupie `docker`
- Narzędzia: zainstalowany program `make`

Struktura plików

- Dockerfile - definicja obrazu (Multi-stage build, Python 3.12, Ansible 2.16)
- Makefile - skrypty pomocnicze do budowania i testowania obrazu
- requirements.txt - biblioteki dla Python
- requirements.yml - kolekcje Ansible (cisco.aci)

## Alma Linux

Po zainstalowaniu systemu operacyjnego warto uzupełnić go o dodatkowe, przydatne narzędzia:

```bash
dnf install -y \
  mc vim \
  traceroute tcpdump wireshark mtr curl wget telnet nmap \
  epel-release open-vm-tools \
  tmux jq git
```

## Docker

### Instalacja

```bash
sudo dnf update -y
sudo dnf install -y dnf-plugins-core jq openssl
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker ${USER}
```

### Obraz

1. Budowanie obrazu

Aby zbudować obraz lokalnie na maszynie runnera, wykonaj:

```bash
make build
```

Polecenie to stworzy obraz aci-automation:1.0.0 oraz otaguje go jako latest.

2. Testowanie lokalne

Przed uruchomieniem workflow w GitHub, warto sprawdzić czy środowisko działa poprawnie, wchodząc do interaktywnej powłoki kontenera:

```bash
make test
```

Wewnątrz kontenera możemy zweryfikować wersje narzędzi:

```bash
python3 --version
ansible --version
ansible-galaxy collection list
```

## Runner

### Przygotowanie użytkownika

```bash
sudo useradd --system \
  --shell /bin/bash \
  --comment "GitHub Action Runner" \
  --create-home \
  --home-dir /opt/github-runner \
  gh-runner

sudo chown -R gh-runner:gh-runner /opt/github-runner
sudo chmod -R 700 /opt/github-runner

sudo usermod -aG docker gh-runner
```

### Instalacja

*Repo > Settings > Actions > Runners > New self-hosted runner*

Instalacja Runner odbywa się zgodnie z instrukcją zawartą na stronie GH

### Konfiguracja w GitHub Actions

W pliku workflow (.yml) należy wskazać runnera oraz przygotowany obraz:

```yaml
jobs:
  aci_task:
    runs-on: self-hosted
    container:
      image: aci-automation:1.0.0
    steps:
      - uses: actions/checkout@v4
      - name: Run Playbook
        run: ansible-playbook playbooks/site.yml
```

## Zmienne środowiskowe

Zmienne, definiowane w GH i używane do łączenia się z ACI, są automatycznie przekazywane do kontenera za pomocą sekcji env w pliku workflow

## Informacje końcowe

**Informacja prawna**

> Niniejszy zasób udostępniany jest w postaci „tak jak jest”. Autor nie daje żadnej gwarancji, wprost lub domniemanej, dotyczącej funkcjonalności czy przydatności. Autor nie ponosi żadnej odpowiedzialności za jakiekolwiek szkody, straty lub konsekwencje wynikające z użytkowania lub niemożności użytkowania niniejszego zasobu i jego zawartości. Korzystasz na własne ryzyko.

**AI**

> AI assited coding

