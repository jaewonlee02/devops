# ---------------------------------------------------------------
# 학생 과제: 아래 각 줄이 무엇을 하는지 주석으로 설명을 달아보세요.
# ---------------------------------------------------------------

FROM python:3.12-slim 
#1. 해당 파이썬 버전으로 실행 

WORKDIR /app
#2.  /app 디렉터리를 작업디렉토리로 지정 

COPY requirements.txt . 
#3.  require.txt 파일을 이미지에복사 .
RUN pip install --no-cache-dir -r requirements.txt
#4.  require.txt에 파일에 있는 패키지들을 pip를 이용해서 설치 
COPY . .
#5.  다른 코드도 이미지 안으로 복사 

RUN useradd -m appuser
#6. 컨테이너에서 appuser를 생성하고 홈 디렉터리 생성 

USER appuser
#7. appuser로 터미널 이용

ENV APP_TITLE="Jaewonlee의 방명록" \
    THEME_COLOR="#5DF579" \
    HOSTNAME="이재원"
#8. 환경변수들을 변경 

EXPOSE 5000
#9. 컨테이너가 5000번으로 실행한다는걸 문서화 

CMD ["python", "app.py"]
#10. python을 이용해서 app.py 실행 
