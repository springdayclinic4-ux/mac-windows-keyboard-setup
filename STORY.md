# 🪖 윈도우 사용자가 맥에서 단축키 살리려고 한 사투의 기록

> 한 명의 윈도우 20년 사용자가 맥북 프로를 처음 받고 단축키 감각을 그대로 쓰려고 한 약 4시간의 여정. 우리가 거친 함정과 해결을 시간순으로 기록. 같은 길을 가는 사람의 시간을 줄여주기 위해.

**환경**: macOS Sequoia 15+ / 맥북 내장 키보드 + USB 윈도우 키보드 + 외부 마우스
**최종 결과물**: [README.md](README.md), [INSTALL.md](INSTALL.md), [install.sh](install.sh) — 새 맥에서 한 줄로 복원 가능

---

## 0. 시작점 — "맥은 씨발 왤캐 불편해"

윈도우에서 맥으로 옮긴 직후의 좌절:
- `Ctrl+C` 안 됨, `Cmd+C` 써야 됨
- `Win+E` 탐색기 단축키 = 맥엔 없음
- 창 좌우 분할 = 기본 없음 (Sequoia 이전엔 더 심각)
- 한영 전환 = 기본 `Caps Lock` (느리고 어색)
- `Alt+Tab` 창 전환 = 맥 `Cmd+Tab`은 **앱** 단위 (창 단위 아님)
- `Home`, `End`, `Page Up/Down` = 일부 앱에서 동작 X
- `Print Screen` = 키 자체가 없음
- 드래그 앤 드롭으로 앱 설치하는 문화

목표: **윈도우 감각 그대로**. 단축키 거의 100% 재현.

---

## 1. 시도 ① — 시스템 설정만으로 해결 (실패)

`시스템 설정 → 키보드 → 키보드 단축키 → 수정자 키` 에서 Ctrl ↔ Cmd 스왑 가능.

**결과**: 수정자 키 4개만 바꿀 수 있고, 키별 동작·앱별 예외 처리 불가능. 초보적.

---

## 2. 시도 ② — Karabiner-Elements 설치 (1차 함정)

```bash
brew install --cask karabiner-elements
```

**함정 1**: `sudo` 비밀번호 필요. Claude Code가 백그라운드로 실행하면 비밀번호 입력 못 받아서 영원히 hang.

**해결**: 사용자가 직접 터미널에서 실행하고 비밀번호 한 번 입력. **macOS DriverKit 설치는 자동화 절대 불가** (애플 보안 정책).

---

## 3. 시도 ③ — Simple Modifications로 키 스왑 (2차 함정)

처음엔 `simple_modifications` 로 좌측 Option ↔ Cmd 스왑하고, `complex_modifications` 로 윈도우 키 단축키(Option+E → Finder 등) 매핑.

**함정 2**: `Option+E` 눌러도 Finder 안 열림. `Option+←` 누르면 줄 맨 앞으로 가버림.

**원인**: Karabiner의 처리 순서 — `simple_modifications`가 **먼저** 처리됨. 그러면 사용자가 `Option` 누르는 순간 즉시 `Command`로 변환되어, `complex_modifications`의 `mandatory: ["left_option"]` 조건은 매칭 실패.

**해결**: 스왑을 `complex_modifications`의 **맨 마지막 규칙**으로 옮기고, Windows 키 단축키들의 mandatory를 **`left_command` 기준**(스왑 후 상태)으로 변경.

```json
// 잘못된 접근
"simple_modifications": [
  {"from": {"key_code": "left_option"}, "to": [{"key_code": "left_command"}]}
],
"complex_modifications": {
  "rules": [
    {"manipulators": [
      {"from": {"key_code": "e", "modifiers": {"mandatory": ["left_option"]}}, ...}  // 매칭 X
    ]}
  ]
}

// 옳은 접근
"complex_modifications": {
  "rules": [
    // 1. Windows 키 단축키 먼저 (스왑 후 left_command 기준)
    {"manipulators": [
      {"from": {"key_code": "e", "modifiers": {"mandatory": ["left_command"]}}, ...}
    ]},
    // 2. 마지막에 스왑
    {"manipulators": [
      {"from": {"key_code": "left_option"}, "to": [{"key_code": "left_command"}]}
    ]}
  ]
}
```

---

## 4. 시도 ④ — 드라이버 확장 미승인 (3차 함정 — 가장 큰 함정)

설정은 다 맞췄는데 **모든 키 매핑이 동작 안 함**. `Cmd+T`도 안 됨.

진단:
```bash
pgrep -l karabiner_grabber  # 결과 없음
```

**원인**: Karabiner의 시스템 확장(DriverKit)이 macOS 보안에 의해 차단됨. 드라이버가 안 떠서 `karabiner_grabber` 데몬도 실행 안 됨. 그래서 키 이벤트를 캡처조차 못 함.

**해결**:
1. 시스템 설정 → 개인정보 보호 및 보안 → **스크롤 맨 아래 "보안" 섹션**
2. *"시스템 소프트웨어 'Fumiaki Takahashi' 가 차단되었습니다"* + **[허용]** 버튼
3. 비밀번호 입력 + **재부팅**

이 단계가 존재한다는 걸 모르면 영원히 헤맴. 우리도 30분 헤맸음.

---

## 5. 시도 ⑤ — Karabiner-Core-Service 권한 별도 (4차 함정)

Karabiner 15.x부터는 `karabiner_grabber`가 **`Karabiner-Core-Service`로 통합**됨. 그런데 macOS는 이 새 프로세스를 **별도 권한 항목**으로 취급.

```bash
pgrep -l Karabiner-Core-Service  # 미실행
```

**원인**: 입력 모니터링에 `Karabiner-Core-Service`가 등록 안 됨. 또는 등록됐지만 토글 OFF.

**해결**:
1. Privileged Daemons 앱 한 번 실행:
   ```bash
   open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Privileged Daemons v2.app"
   ```
2. 시스템 설정 → 일반 → 로그인 항목 및 확장 프로그램 → "백그라운드에서 허용" → `Fumiaki Takahashi` ON
3. 입력 모니터링 → `Karabiner-Core-Service` 토글 ON

---

## 6. 시도 ⑥ — 외부 키보드 한/영 키가 안 먹힘 (5차 함정)

외부 USB 윈도우 키보드의 한/영 키 누름 → EventViewer 보면 `japanese_kana` 신호는 정확히 들어옴. 그런데 **시스템에선 한영 전환 안 됨**.

내장 키보드의 우측 Cmd → `japanese_kana` 매핑은 잘 동작. 차이가 뭘까?

**원인**: macOS는 **키보드별로 입력 소스를 분리 추적**. 외부 키보드는 영문(ABC) 전용으로 인식되어, 그 키보드에서는 일본어 가나 키를 무시.

**해결**: `japanese_kana` 신호 보내지 말고, Karabiner의 **`select_input_source` 액션으로 시스템 입력기를 직접 토글**.

```json
{
  "from": {"key_code": "japanese_kana"},
  "conditions": [{"type": "variable_if", "name": "korean_input_active", "value": 1}],
  "to": [
    {"select_input_source": {"input_source_id": "com.apple.keylayout.ABC"}},
    {"set_variable": {"name": "korean_input_active", "value": 0}}
  ]
},
{
  "from": {"key_code": "japanese_kana"},
  "to": [
    {"select_input_source": {"input_mode_id": "com.apple.inputmethod.Korean.2SetKorean"}},
    {"set_variable": {"name": "korean_input_active", "value": 1}}
  ]
}
```

키보드 종류 무관하게 작동. variable로 토글 상태 추적.

---

## 7. 시도 ⑦ — Cmd+D 가 Mission Control이 돼서 터미널 분할 안 됨 (6차 함정)

Warp/iTerm2에서 `Cmd+D`는 세로 분할 단축키. 그런데 우리 매핑이 `Option+D` (= 스왑돼서 Cmd+D 신호) → Mission Control 으로 잡아버림.

**해결**: `frontmost_application_unless` 조건으로 터미널 앱 **bundle ID 7개**를 예외 처리.

```json
"conditions": [{
  "type": "frontmost_application_unless",
  "bundle_identifiers": [
    "^com\\.apple\\.Terminal$",
    "^com\\.googlecode\\.iterm2$",
    "^dev\\.warp\\.Warp-Stable$",
    "^net\\.kovidgoyal\\.kitty$",
    "^org\\.alacritty$",
    "^com\\.github\\.wez\\.wezterm$",
    "^co\\.zeit\\.hyper$"
  ]
}]
```

같은 패턴을 `Ctrl+C/V/X/Z/A` 에도 적용 (터미널에선 `Ctrl+C` = SIGINT).

---

## 8. 시도 ⑧ — 외부 키보드 비표준 keycode (7차 함정)

저가 USB 키보드(Hengchangtong HCT)의 `End` 키를 누르니 EventViewer에 `left_command` 표시.

**원인**: 키보드 펌웨어 자체가 비표준 신호를 보냄. macOS도 Karabiner도 어쩔 수 없음.

**해결**: 다른 키보드로 바꾸거나, 키보드의 Mac 모드 토글(`Fn+M` 같은 거) 시도. 펌웨어 단의 문제는 OS/소프트웨어로 우회 불가.

---

## 9. 시도 ⑨ — 마우스 휠 자연 스크롤 분리 (보너스 함정)

`defaults write -g com.apple.swipescrolldirection -bool false` 로 자연 스크롤 끄면 **트랙패드와 마우스 둘 다** 윈도우 방향이 됨.

**문제**: 트랙패드는 자연 스크롤이 직관적. 마우스만 윈도우 방향으로 분리하고 싶음.

**해결**: **Mos** 무료 앱.
```bash
brew install --cask mos
```
마우스 방향만 별도 처리. 트랙패드는 자연 스크롤 유지 가능.

---

## 10. 시도 ⑩ — 디바이스별 modify_events 활성화 (8차 함정)

새 키보드 꽂으면 자동 적용 안 됨. Karabiner의 `devices` 섹션에 명시적으로 등록되어야 함.

**해결**: 일반 식별자로 모든 미래 디바이스 자동 활성화.

```json
"devices": [
  {"identifiers": {"is_pointing_device": true}, "modify_events": true},
  {"identifiers": {"is_keyboard": true}, "modify_events": true}
]
```

USB든 블루투스든 새 디바이스 → 자동 적용.

---

## 11. 시도 ⑪ — Trackpad 한 번에 윈도우식으로 (정리)

`defaults write` 명령어로 한 번에:

```bash
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true               # 탭으로 클릭
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true # 세 손가락 드래그
defaults write -g com.apple.swipescrolldirection -bool false                       # 자연 스크롤 끄기
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5                # 속도 2.5x
```

**탭하여 클릭** + **세 손가락 드래그** 조합이 진짜 게임체인저. 손목 통증 사라짐.

---

## 12. 시도 ⑫ — Alt+PrtSc로 활성 창 캡처 (9차 함정)

윈도우의 `Alt+PrtSc` = 현재 활성 창만 캡처해서 클립보드 복사. 맥 기본은 영역 선택만 가능.

**해결**: AppleScript로 활성 창 ID 가져와서 `screencapture -l<id> -c`.

```bash
WIN=$(osascript -e 'tell application "System Events" to id of front window of (first application process whose frontmost is true)')
screencapture -l$WIN -c -o
```

`-c` 클립보드, `-o` 그림자 제외.

Karabiner shell_command 액션으로 호출:
```json
"to": [{"shell_command": "WIN=$(osascript -e '...') && screencapture -l$WIN -c -o"}]
```

⚠️ macOS 자동화 권한 필요 (System Events).

---

## 13. 부록 — 자동화의 한계

`install.sh` 만들면서 깨달은 것:

**자동 가능**:
- Homebrew 앱 설치 (sudo 비밀번호 1회만)
- Karabiner JSON 설정 복사
- defaults write (트랙패드/Finder)
- 시스템 설정 창 띄우기 (사용자가 클릭은 직접)

**자동 절대 불가** (애플 보안 정책):
- 드라이버 확장 승인 ([허용] 버튼)
- TCC 권한 토글 (입력 모니터링·손쉬운 사용·화면 기록)
- 재부팅
- 권한 거부된 후 다시 동의

**최선의 자동화 = 80%** + 사용자가 클릭 6번 + 재부팅 1번.

---

## 14. 최종 통계

- 거친 함정: **9가지**
- 작성한 Karabiner 규칙: **20개**
- 매핑된 키 조합: **약 70개**
- 설치한 앱: **4종** (Karabiner / Rectangle / AltTab / Mos)
- 시스템 설정 변경: **9가지**
- 재부팅: **2회**
- 소요 시간: **약 4시간**
- GitHub 커밋: **6회**

새 맥에서 같은 환경 복원하는 데 걸리는 시간:
- **5~10분** (`bash install.sh` + 권한 클릭 6번 + 재부팅 1회)

---

## 15. 핵심 교훈

1. **macOS의 보안 모델은 자동화의 적**. 애플은 의도적으로 모든 권한 부여를 사람 손가락 거치게 만들었다.
2. **Karabiner의 simple vs complex 처리 순서를 모르면 영원히 헤맨다**. 모든 매핑은 complex로.
3. **드라이버 확장 미승인은 가장 흔한 함정**. 이거 모르면 "다 깔았는데 왜 안 됨?" 무한 루프.
4. **외부 키보드는 별개의 우주**. 입력 소스, 매핑, keycode 모두 분리 처리됨.
5. **저가 키보드는 펌웨어부터 비표준**. 소프트웨어로 못 고침. 키보드를 바꾸는 게 답.
6. **저장소 + 자동 스크립트 = 미래의 나에게 주는 선물**. 새 맥 살 때 4시간 → 10분.

---

## 마치며

이 프로젝트는 단순히 키 매핑을 만든 게 아니라, **윈도우/맥의 철학적 차이를 단축키라는 표면에서 화해시킨 작업**이다.

만약 같은 길을 가고 있다면, 이 저장소를 그대로 가져가서 시간을 아끼시길.

---

**작성**: 권오성 / Claude (Sonnet via Cursor → Opus via Claude Code)
**날짜**: 2026-04-25 ~ 2026-04-26
**저장소**: https://github.com/springdayclinic4-ux/mac-windows-keyboard-setup
