# 6주차: Dockerfile 및 방명록 이미지 만들기 정리

## 1. 오늘 배운 핵심 내용
- Dockerfile의 각 명령어 역할
- 이미지를 빌드하고 컨테이너로 실행하는 과정
- 레이어 캐시와 COPY 순서
- 환경변수로 제목과 색상 변경
- 이미지 태그, 레지스트리 공유, 멀티 아키텍처 빌드

---

## 2. 방명록 앱 구조
실습 코드는 [guestbook](../guestbook/) 폴더에 있다.

| 파일 | 역할 |
| :--- | :--- |
| `app.py` | Flask 웹 앱과 방명록 처리 |
| `templates/index.html` | 방명록 화면 |
| `requirements.txt` | Flask와 Redis 패키지 버전 |
| `Dockerfile` | 이미지 빌드와 실행 방법 |
| `Dockerfile.bad` | 전체 코드를 먼저 복사하는 비교 예제 |
| `Dockerfile.multistage` | 단계를 나누어 필요한 결과물을 복사하는 예제 |
| `.dockerignore` | 빌드 컨텍스트에서 제외할 파일 |

## 3. Dockerfile 각 줄 설명

다.

| 명령어 | 하는 일 |
| :--- | :--- |
| `FROM python:3.12-slim` | Python 3.12가 포함된 기본 이미지 선택 |
| `WORKDIR /app` | 이후 작업 위치를 /app으로 지정 |
| `COPY requirements.txt .` | 패키지 목록부터 이미지에 복사 |
| `RUN pip install --no-cache-dir -r requirements.txt` | 이미지 빌드 중 필요한 패키지 설치 |
| `COPY . .` | 앱 코드와 템플릿 복사 |
| `RUN useradd -m appuser` | 홈 디렉터리를 가진 사용자 생성 |
| `USER appuser` | 이후 명령과 앱을 appuser 권한으로 실행 |
| `ENV ...` | 제목과 색상 등 기본 환경변수 지정 |
| `EXPOSE 5000` | 앱이 사용할 포트 정보 표시 |
| `CMD ["python", "app.py"]` | 컨테이너 시작 시 앱 실행 |

`RUN`은 이미지를 만들 때 실행하고, `CMD`는 컨테이너를 시작할 때 실행한다. `EXPOSE`만으로 호스트 포트가 열리는 것은 아니므로 실행할 때 `-p`로 연결해야 한다.

## 4. 이미지 빌드와 실행

```bash
# 저장소 최상위 폴더에서 이동
cd guestbook
docker build -t guestbook:v1 .
docker run -d -p 8080:5000 --name guestbook-week06 guestbook:v1
docker ps
curl -I http://localhost:8080
docker logs guestbook-week06
```

이미지는 실행 환경을 담은 틀이고, 컨테이너는 그 이미지로 실행한 인스턴스이다. 8080번 포트가 사용 중이면 `-p 8081:5000`처럼 호스트 쪽 포트를 바꾸고 접속 주소도 바꾼다.

## 5. 레이어 캐시와 파일 복사 순서
현재 Dockerfile은 requirements.txt를 먼저 복사하고 패키지를 설치한 다음 앱 코드를 복사한다.

```dockerfile
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

앱 코드만 바뀌면 패키지 설치 단계의 캐시를 다시 사용할 수 있다. 반대로 Dockerfile.bad처럼 `COPY . .`를 먼저 하면 앱 코드 수정 때문에 뒤의 패키지 설치 단계도 다시 실행될 수 있다. `pip --no-cache-dir`는 pip 다운로드 캐시 옵션이므로 Docker 빌드 캐시와는 별개이다.

```bash
# 변경 없이 다시 빌드하여 CACHED 표시 확인
docker build --progress=plain -t guestbook:v1 .
```


## 6. 환경변수로 설정 바꾸기

| 설정 위치 | 적용 시점 | 바꾸는 방법 |
| :--- | :--- | :--- |
| app.py 기본값 | 환경변수가 없을 때 사용 | 코드 수정 후 재빌드 |
| Dockerfile ENV | 이미지의 기본 환경변수 | Dockerfile 수정 후 재빌드 |
| docker run -e | 컨테이너 실행 시 | 옵션을 바꾸어 새 컨테이너 실행 |

APP_TITLE과 THEME_COLOR는 실행 시 `-e`로 지정한 값이 이미지의 ENV보다 우선한다.

```bash
docker run -d -p 8081:5000 --name guestbook-custom \
  -e APP_TITLE="이재원의 방명록" \
  -e THEME_COLOR="#5DF579" \
  guestbook:v1
```

Dockerfile에는 HOSTNAME="이재원"도 적혀 있다. 다만 app.py는 환경변수 HOSTNAME을 읽지 않고 `socket.gethostname()`을 사용한다. 따라서 이 ENV만 바꿔도 화면 hostname이 이재원으로 바뀐다고 설명할 수는 없다.

## 7. 이미지 주소와 공유 흐름
이미지 주소는 `레지스트리/계정/이미지:태그`로 읽는다.

```bash
# PPT에 적어 둔 tag와 push 과정을 현재 GitHub 계정으로 표시한 예시
docker tag guestbook:v1 ghcr.io/jaewonlee02/guestbook:v1
docker push ghcr.io/jaewonlee02/guestbook:v1
```
.


### 멀티 아키텍처
CPU 아키텍처가 다르면 이미지 실행이 안 될 수 있다. 수업에서는 buildx로 여러 플랫폼 이미지를 함께 만드는 방법을 다룬다.

```bash
# 레지스트리 로그인 및 buildx 빌더 설정 후 사용하는 예시
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ghcr.io/jaewonlee02/guestbook:v1 --push .
```

## 8. 멀티스테이지 빌드
Dockerfile.multistage는 builder 단계에서 패키지를 설치하고, 최종 단계로 필요한 파일을 복사한다. 빌드용 도구를 최종 이미지에서 제외하는 데 사용할 수 있다. 이 예제는 양쪽 모두 python:3.12-slim을 사용하므로 용량이 크게 줄어드는지는 직접 비교해야 한다.

```bash
docker build -f Dockerfile.multistage -t guestbook:multistage .
docker images | grep guestbook
```


## 10. 혼자 해보기

Dockerfile의 제목과 색상, `templates/index.html`의 문구와 방문 횟수 표시를 바꾼 기존 방명록을 이번에 다시 빌드했다. 기존 `v2` 태그는 덮어쓰지 않으려고 `practice-20261023` 태그를 사용했다.

| 실습 | 확인한 결과 |
| :--- | :--- |
| 이미지 빌드와 재빌드 | `guestbook:practice-20261023` 빌드 성공. 같은 명령으로 다시 빌드하니 `#6`~`#10` 단계가 `CACHED`로 표시됐다. |
| 내 방명록 화면 | 8081번에서 제목과 테마를 확인했다. 실행 시 `-e THEME_COLOR="#C6A15B"`를 넣은 [화면 캡처](c.png)이다. |
| GHCR push/pull | `ghcr.io/jaewonlee02/guestbook:practice-20261023`을 push했다. 원격 태그를 로컬에서 지운 뒤 다시 pull하니 `Downloaded newer image`가 나왔고, 8084번에서 `/readyz`의 `ready` 응답을 확인했다. |
| 기존 이미지 위에 ENV 추가 | 교안의 친구 이미지 `ghcr.io/makyraen/inhatc-devops-guestbook:v1`은 pull에 실패했다. 내 이미지 `ghcr.io/jaewonlee02/guestbook:v1`로 대체해 [Dockerfile.custom](../guestbook/Dockerfile.custom)을 빌드했고 `guestbook:custom-practice-20261023` 이미지가 만들어졌다. |
| 설정 우선순위 | 파생 이미지의 ENV 색상은 8082번 [화면](a.png)에서 `#7C9A82`였다. 같은 이미지에 `-e THEME_COLOR="#16a34a"`를 준 8083번 [화면](b.png)에는 `#16a34a`가 적용됐다. |

재빌드에서는 `#6 CACHED`, `#7 CACHED`, `#8 CACHED`, `#9 CACHED`, `#10 CACHED`가 나왔다. 이번에 push한 태그의 digest는 `sha256:4d05a373d754880392265447e091e4111e1cc5205992c80da2f7cec2dc9b8490`이다. 친구 이미지를 실행했다는 결과로 적지 않고, 내 이미지로 같은 ENV 실습을 대신했다.
