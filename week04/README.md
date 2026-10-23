# 4주차: 네트워크 기본 개념 및 웹 서버 실행 정리

## 1. 오늘 배운 핵심 내용
- IP 주소와 포트의 역할
- DNS를 이용한 도메인 이름 조회
- `ping`, `curl`, `ss`로 연결 및 서비스 상태 확인
- Python 웹 서버 실행과 포트 충돌 해결

---

## 2. IP 주소, 포트, DNS

| 구분 | 역할 | 예시 |
| :--- | :--- | :--- |
| IP 주소 | 네트워크에서 장치를 찾는 주소 | 사설 IP `192.168.x.x`, 루프백 `127.0.0.1` |
| 포트 | 같은 컴퓨터 안의 서비스를 구분하는 번호 | HTTP 80, HTTPS 443, 개발용 8080 |
| DNS | 도메인 이름에 대응하는 IP 주소 조회 | `dig cs.inhatc.ac.kr +short` |
| NAT | 사설망의 주소를 변환하여 외부와 통신 | 공유기를 통한 인터넷 연결 |

`localhost`는 내 컴퓨터를 가리킨다. `0.0.0.0`에 서버를 바인딩하면 모든 IPv4 인터페이스에서 요청을 받는다. 실제로 외부에서 접속할 수 있는지는 방화벽과 네트워크 설정도 확인해야 한다.

## 3. 네트워크 확인 명령어
```bash
ip addr
hostname -I
ping -c 4 127.0.0.1
dig cs.inhatc.ac.kr +short
curl -I https://cs.inhatc.ac.kr
ss -tlnp
```

| 명령어 | 확인하는 내용 |
| :--- | :--- |
| `ip addr` | 네트워크 인터페이스와 IP 주소 |
| `ping` | ICMP 응답 여부 |
| `dig` | DNS 조회 결과 |
| `curl -I` | HTTP 응답 헤더와 상태 코드 |
| `ss -tlnp` | LISTEN 상태인 TCP 포트와 프로세스 |

ping 응답이 없다고 웹 서버까지 꺼졌다고 판단하면 안 된다. ICMP를 차단할 수도 있으므로 curl로 HTTP 응답도 확인한다.

## 4. Python 웹 서버 실행

실습 페이지는 [site/index.html](site/index.html)에 있다. 페이지 제목은 `Very first server`이고 본문에는 `Server`, `This page is running.`이 들어 있다.

```bash
# 저장소 최상위 폴더에서 실행
cd week04/site
python3 -m http.server 8080
```

다른 터미널에서 확인한다.
```bash
curl http://localhost:8080
curl -I http://localhost:8080
ss -tlnp | grep ':8080'
```

브라우저에서는 `http://localhost:8080`으로 접속한다. 서버를 실행한 터미널에서 Ctrl+C로 종료한다.

### 포트 충돌 해결
같은 주소의 8080번 포트를 다른 프로그램이 사용하면 `Address already in use` 오류가 날 수 있다.

1. `ss -tlnp`로 8080번 포트를 사용하는 프로세스를 확인한다.
2. 직접 실행한 서버라면 해당 터미널에서 Ctrl+C로 종료한다.
3. 기존 서버를 유지해야 한다면 새 서버는 다른 포트로 실행한다.

```bash
python3 -m http.server 8000
# 변경한 포트로 접속
curl -I http://localhost:8000
```

## 5. HTTP 응답 코드

| 코드 | 의미 |
| :--- | :--- |
| 200 | 요청 성공 |
| 400 | 잘못된 요청 |
| 404 | 요청한 리소스 없음 |
| 500 | 서버 내부 오류 |
| 503 | 서비스 사용 불가 |

HTTP 오류 응답을 받았으면 서버에서 응답을 보냈다는 뜻이다. 연결 자체가 안 되는 경우와 요청 처리 중 오류가 난 경우를 구분해야 한다.

## 6. 폴더에 함께 있는 셸 실습 파일
네트워크 실습 파일 외에 앞에서 다룬 셸 스크립트도 이 폴더에 남아 있다.

| 파일 | 정리 내용 |
| :--- | :--- |
| `backup.sh` | 폴더 확인, 날짜와 PID로 파일명 생성, tar 압축과 종료 코드 확인 |
| `check.sh` | 인자로 받은 경로가 파일인지 디렉터리인지 구분 |
| `greet.sh` | 위치 인자와 인자 개수 확인 |
| `var.sh` | 변수와 명령어 치환 |
| `server.log`, `errors.txt` | 로그에서 ERROR 행을 추려 확인 |

```bash
# week04 폴더에서 실행하는 예시
bash check.sh site
bash greet.sh 이재원
grep ERROR server.log
```

