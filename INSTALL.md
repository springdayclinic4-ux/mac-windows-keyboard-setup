# 새 맥에서 복원하기 — 단계별 가이드

이 문서는 **실전에서 우리가 막혔던 함정을 모두 반영**한 시간순 가이드입니다. 위에서 아래로 그대로 따라가세요.

---

## 0. 사전 준비

- [ ] macOS 14 (Sonoma) 이상 권장 (15 Sequoia가 가장 안정적)
- [ ] 관리자 권한 계정으로 로그인
- [ ] 30분~1시간 여유 (재부팅 1회 + 권한 허용 클릭 다수)
- [ ] **물리 키보드 접근 가능** (재부팅 후 권한 허용해야 함)

---

## 1. Homebrew 설치 (없으면)

터미널 열고:

```bash
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

설치 끝나면 안내대로 PATH 등록 명령(2줄)을 복사해서 그대로 실행.

---

## 2. 이 저장소 받기

```bash
cd ~/Desktop
gh auth login   # GitHub 로그인 안 돼 있으면 (Web → HTTPS → 브라우저 인증)
gh repo clone springdayclinic4-ux/mac-windows-keyboard-setup
cd mac-windows-keyboard-setup
```

또는 ZIP 다운로드:
https://github.com/springdayclinic4-ux/mac-windows-keyboard-setup

---

## 3. 자동 설치 스크립트 실행

```bash
bash install.sh
```

이 스크립트가 자동으로 처리하는 것:
- Karabiner-Elements / Rectangle / AltTab / Mos 설치
- 설정 파일 + 프리셋 적절한 위치로 복사
- 트랙패드 기본 설정 (탭 클릭 / 세 손가락 드래그 / 자연 스크롤 끄기)
- Finder 기본 설정 (숨김 파일 / 경로 막대 / 확장자 표시)
- 스크린샷 저장 위치 `~/Screenshots`

**중간에 비밀번호 1~2회 입력 필요** (Karabiner DriverKit 설치 단계).

---

## 4. ⚠️ 드라이버 확장 활성화 (가장 흔한 함정)

자동으로 안 됩니다. **반드시 수동**:

1. **시스템 설정 → 개인정보 보호 및 보안**
2. 스크롤을 **맨 아래**로 내려서 **"보안"** 섹션 확인
3. *"시스템 소프트웨어 'Fumiaki Takahashi' 또는 'pqrs.org' 가 차단되었습니다"* 메시지 + **"허용"** 버튼
4. **허용 클릭** → 비밀번호 입력
5. **"재시동 필요"** 안내 → 재부팅 ← **반드시 재부팅**

이걸 안 하면 **Karabiner의 `karabiner_grabber` 데몬이 영원히 실행 안 됩니다**. 모든 키 매핑이 작동 안 함.

---

## 5. 재부팅 후 ─ 권한 허용 (3종)

`bash install.sh`를 한 번 더 실행하면 권한 창들을 순서대로 띄워줍니다 (또는 수동으로 시스템 설정 들어가기).

### A. 입력 모니터링 (System Settings → Privacy & Security → Input Monitoring)

목록에 아래 항목들이 자동 등장. **모두 토글 ON**:
- ✅ `Karabiner-Elements`
- ✅ `Karabiner-Core-Service` ← **이 항목이 안 보이면 6단계로**
- ✅ `karabiner_session_monitor`

### B. 손쉬운 사용 (Accessibility)

- ✅ `Karabiner-Elements`
- ✅ `Rectangle`
- ✅ `AltTab`
- ✅ `Mos`

### C. 화면 기록 (Screen Recording)

- ✅ `AltTab` (창 썸네일 캡처용)

### D. 로그인 항목 (백그라운드에서 허용)

자동 등록되어야 정상이지만 확인:
- ✅ `Karabiner-Elements Privileged Daemons v2.app`
- ✅ `Karabiner-Elements Non-Privileged Agents v2.app`

---

## 6. ⚠️ Karabiner-Core-Service가 입력 모니터링에 안 보이면

Karabiner 15.x에서 발생. 우리도 여기서 막혔음.

```bash
pgrep -l karabiner
```

`Karabiner-Core-Service` 가 안 보이면 daemon 미등록 상태. 다음 실행:

```bash
open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Privileged Daemons v2.app"
open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents v2.app"
```

비밀번호 입력 → 시스템 설정 → 일반 → **로그인 항목 및 확장 프로그램** → "백그라운드에서 허용" 섹션에 **`Fumiaki Takahashi`** 토글 ON.

그 후 재부팅 한 번 더 → 5단계 권한 다시 확인.

---

## 7. 한국어 입력기 등록

```bash
defaults read com.apple.HIToolbox AppleEnabledInputSources | grep -i korea
```

결과 없으면:
1. **시스템 설정 → 키보드 → 입력 소스** → **"편집"** 클릭
2. 좌측 하단 **`+`** → **"한국어"** → **"2벌식"** 추가

(이게 없으면 한/영 전환 자체가 의미 없음)

---

## 8. 외부 키보드 첫 연결 시 (USB / 블루투스)

1. macOS가 **"키보드 식별 도우미"** 창을 띄움 → 시키는 대로 키 누르기 (보통 좌Shift 옆 키 찾기)
2. **ANSI / ISO / JIS** 중 **ANSI** 선택 (한국 키보드 대부분)
3. 자동으로 Karabiner의 `is_keyboard: true` 조건 매칭 → 모든 매핑 즉시 적용

---

## 9. 작동 확인 (1분)

브라우저(Chrome/Safari) 열고:

| 테스트 | 기대 |
|---|---|
| `Ctrl + T` | 새 탭 |
| `Ctrl + ←/→` | 단어 이동 (텍스트 입력 시) |
| `Option + E` | Finder 새 창 |
| `Option + ←/→` | Rectangle 좌/우 분할 |
| 좌측 `Cmd + Tab` | AltTab 창 전환 (윈도우 Alt+Tab 화면) |
| 우측 `Command` | 한/영 전환 |
| `Option + D` | Mission Control |

**하나라도 안 되면**: 5단계 권한 + 6단계 daemon 점검.

---

## 10. 흔한 함정 정리

| 증상 | 원인 | 해결 |
|---|---|---|
| 모든 단축키 안 먹힘 | `karabiner_grabber` (Core-Service) 안 돎 | 4단계 드라이버 확장 + 5단계 권한 + 재부팅 |
| Core-Service가 입력 모니터링에 안 뜸 | Privileged Daemons 미실행 | 6단계 |
| Option+키만 안 됨 | Karabiner-Elements 앱 미실행 (메뉴바 아이콘 X) | `open -a Karabiner-Elements` |
| Option+방향키 → 이상한 동작 (소리 등) | Rectangle 미실행 | `open -a Rectangle` + 손쉬운 사용 권한 |
| 좌측 Cmd+Tab → 맥 기본 앱 전환만 됨 | AltTab 미실행 | `open -a AltTab` + 권한 |
| 한/영 키 안 먹힘 | 한국어 입력기 미등록 | 7단계 |
| End 키가 이상한 동작 (left_command 등) | 키보드 펌웨어 비표준 (저가 중국제) | 다른 키보드 사용 또는 키보드의 Mac 모드 토글 |
| Karabiner 설정 변경했는데 적용 안 됨 | 자동 감지 실패 | `osascript -e 'quit app "Karabiner-Elements"' && open -a Karabiner-Elements` |

---

## 11. 참고

- **Karabiner 공식 문서**: https://karabiner-elements.pqrs.org/docs/
- **rux616/karabiner-windows-mode**: https://github.com/rux616/karabiner-windows-mode
- **EventViewer로 키 진단**: `/Applications/Karabiner-EventViewer.app`
- 우리가 거친 실전 케이스 전체: 본 저장소의 commit history 참조
