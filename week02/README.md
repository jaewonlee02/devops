# 2주차: 실습 환경 구축과 버전 관리 (WSL, Linux, Git)

## 1. 인프라 운영 방식 및 가상화 비교

| 구분 | 개념 및 특징 | 대표 예시 |
| :--- | :--- | :--- |
| **서버 (Server)** | 클라이언트의 요청(Request)을 받아 처리 후 응답(Response)을 전달하는 시스템 | 웹 서버, API 서버 |
| **베어메탈 (Bare Metal)** | 하드웨어(PC) 위에 직접 OS를 설치하고 소프트웨어를 구동 | 개인용 PC, 단일 OS 물리 서버 |
| **하이퍼바이저 (Hypervisor)** | 하드웨어 위에 하이퍼바이저를 올려 여러 개의 독립된 가상 머신(VM, Guest OS)을 실행 | VMware, VirtualBox |
| **컨테이너 (Container)** | 호스트 OS 커널을 공유하며 애플리케이션 실행 환경만 격리하여 가볍고 빠르게 구동 | Docker, Podman |

### 컨테이너의 핵심 기술 (Linux Kernel)
* **네임스페이스 (Namespaces)**: 프로세스(PID), 파일시스템(Mount), 네트워크(Network) 등 각 환경을 논리적으로 분리·격리
* **제어 그룹 (cgroups, Control Groups)**: 프로세스가 사용할 수 있는 시스템 리소스(CPU, 메모리, I/O 등)의 상한선을 제어

---

## 2. WSL (Windows Subsystem for Linux) 환경 구축

### 2.1 WSL의 주요 특징
* **빠른 속도**: 경량 가상화를 통한 빠른 부팅 및 실행 속도
* **시스템 통합**: Windows 파일 시스템 및 터미널과의 완벽한 연동
* **편리한 개발**: 별도의 듀얼 부팅 없이 Windows 내에서 순수 Linux 개발 환경 구축 가능

### 2.2 WSL 기본 관리 명령어 (PowerShell/CMD)
```powershell
# Ubuntu 24.04 배포판 설치
wsl --install -d ubuntu-24.04

# 현재 설치된 배포판 목록 및 실행 상태, WSL 버전 확인
wsl -l -v

# 특정 배포판을 WSL 2 버전으로 변경
wsl --set-version ubuntu-24.04 2

# 기본으로 실행할 배포판 지정
wsl --set-default ubuntu-24.04
```

---

## 3. 리눅스(Ubuntu) 기초 및 시스템 관리 명령어

### 3.1 패키지 관리
```bash
# 패키지 목록을 최신 상태로 갱신 (-y: 설치 확인 프롬프트 자동 승인)
sudo apt update -y
```

### 3.2 시스템 및 사용자 확인
| 명령어 | 설명 |
| :--- | :--- |
| `whoami` | 현재 로그인된 사용자 이름 출력 |
| `who` | 현재 시스템에 로그인 중인 모든 사용자 정보 확인 |
| `id` | 현재 사용자의 UID, GID 및 소속 그룹 정보 확인 |
| `uname -a` | 리눅스 커널 버전, 아키텍처 등 상세 시스템 정보 출력 |
| `df -h` | 디스크 여유 공간 및 사용량을 사람이 읽기 쉬운 단위(GB, MB)로 출력 |
| `free -h` | 현재 시스템의 메모리(RAM) 및 스왑(Swap) 메모리 사용 상태 출력 |

### 3.3 히스토리 및 로그 모니터링
```bash
# 히스토리 기반 명령어 실행
!103        # 히스토리 목록의 103번째 명령어 즉시 실행
!103:p      # 103번째 명령어를 실행하지 않고 확인만 수행
!!          # 직전에 실행한 명령어 다시 실행
!ls         # 가장 최근에 'ls'로 시작했던 명령어 재실행

# 실시간 파일/로그 모니터링
tail -f 로그파일.log  # 파일 끝부분에 추가되는 내용을 실시간으로 스트리밍 확인
```

---

## 4. Git (분산 버전 관리 시스템)

### 4.1 초기 설치 및 환경 설정
```bash
# Git 설치
sudo apt install git -y

# 전역 사용자 정보 및 기본 브랜치 설정
git config --global user.name "사용자이름"
git config --global user.email "사용자이메일"
git config --global init.defaultBranch main

# 설정된 옵션 목록 확인
git config --list
```

### 4.2 기본 작업 흐름 (Workflow)
```bash
# 현재 디렉터리를 Git 저장소로 초기화
git init

# 저장소 작업 트리 상태 확인
git status

# 스테이징 영역(Staging Area)에 파일 추가
git add <파일명>      # 특정 파일 지정
git add .           # 변경된 모든 파일 추가

# 커밋 생성 (버전 기록)
git commit -m "커밋 메시지 작성"

# 커밋 기록 확인
git log             # 상세 기록 확인
git log --oneline   # 커밋 ID와 메시지를 한 줄로 요약 확인
```

### 4.3 버전 탐색 및 비교
* **커밋 체크아웃 (Detached HEAD)**:
  ```bash
  git switch -d <커밋해시>   # 해당 커밋 시점으로 이동 (구분 가능한 앞 7자리 입력 가능)
  ```
* **커밋 간 차이점 비교**:
  ```bash
  git diff <커밋해시1> <커밋해시2>
  # 커밋해시2 기준 새로 추가된 내용(+), 삭제된 내용(-) 비교
  ```

### 4.4 브랜치(Branch) 관리
```bash
# 브랜치 생성과 동시에 전환
git switch -c <브랜치명>

# 기존 브랜치로 전환
git switch <브랜치명>

# 현재 존재하는 브랜치 목록 및 현재 브랜치 확인
git branch
```

---

## 5. GitHub 원격 저장소 연동 (GitHub CLI)

GitHub CLI(`gh`)를 사용하면 터미널에서 원격 저장소 생성부터 푸시까지 한 번에 처리할 수 있습니다.

```bash
gh repo create <레포이름> --public --source=. --remote=origin --push
```

### 옵션 상세 설명
* `<레포이름>`: 생성할 GitHub 원격 저장소의 이름
* `--public`: 저장소를 공개(Public) 형태로 생성
* `--source=.`: 현재 로컬 디렉터리를 소스로 지정하여 저장소에 연결
* `--remote=origin`: 원격 저장소의 식별 이름을 관례적인 이름인 `origin`으로 설정
* `--push`: 로컬 저장소에 커밋된 내용을 새로 생성된 GitHub 원격 저장소에 즉시 업로드