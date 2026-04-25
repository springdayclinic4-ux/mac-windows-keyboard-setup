# 맥북 윈도우식 키보드·트랙패드 설정 (Karabiner + Rectangle + AltTab + Mos)

윈도우 사용자가 맥으로 넘어와도 단축키 감각 그대로 쓸 수 있도록 한 종합 설정 백업.
**새 맥에서 한 번에 복원 가능**, **모든 외부 키보드/마우스/트랙패드에 자동 적용**.

---

## 🤖 Claude Code 사용자 — 한 줄 프롬프트

새 맥에 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 가 설치돼 있다면 터미널에서 `claude` 실행하고 아래 프롬프트 그대로 붙여넣으세요:

```
https://github.com/springdayclinic4-ux/mac-windows-keyboard-setup 이 저장소를 ~/Desktop/mac-keyboard 에 클론하고 INSTALL.md 절차 그대로 install.sh 실행해줘. 권한 허용 단계에서는 시스템 설정 창 띄워주고 어떤 토글을 켜야 하는지 단계별로 알려줘. 중간에 재부팅 필요하면 재부팅 안내해주고, 재부팅 후 다시 시작할 때 verify.sh 로 상태 점검해서 안 된 부분만 골라서 도와줘.
```

Claude Code가 자동으로:
- 저장소 클론
- `install.sh` 실행 (앱 4종 설치, 설정 복사, 트랙패드/Finder 세팅)
- 권한 창 순서대로 띄우기 → 사용자는 토글만 ON 클릭
- daemon 실행 상태 점검
- `verify.sh` 로 최종 검증
- 막힌 곳 자동 진단 + 수정

**소요 시간**: 5~10분 (재부팅 1회 + 권한 클릭 약 6번).

> ⚠️ 100% 자동은 macOS 보안 정책상 불가능합니다. **드라이버 확장 승인** 과 **TCC 권한 토글** 은 Apple이 의도적으로 사용자 클릭만 받게 막아놨어요. 그 외엔 다 자동.

---

## 🧰 직접 설치하는 경우 (Claude Code 없이)

```bash
# 저장소 받기
gh repo clone springdayclinic4-ux/mac-windows-keyboard-setup
cd mac-windows-keyboard-setup

# 자동 설치 (앱 + 설정 + 권한창 띄우기)
bash install.sh

# 설치 후 검증
bash verify.sh
```

**상세 단계별 가이드**: [INSTALL.md](INSTALL.md) — 우리가 실제로 막혔던 함정(드라이버 확장 미승인, daemon 미등록, Core-Service 권한 등)을 모두 반영한 시간순 가이드.

---

## 📦 포함된 파일

| 파일 | 용도 |
|---|---|
| `install.sh` | 자동 설치 스크립트 (idempotent — 몇 번 실행해도 안전) |
| `verify.sh` | 권한·실행 상태 자동 검증 |
| `INSTALL.md` | 시간순 11단계 설치 가이드 + 함정 표 |
| `맥_윈도우식_단축키_설정.md` | 모든 단축키 매핑 + 권한 체크 + 트러블슈팅 (참조용) |
| `karabiner_백업_20260425.json` | Karabiner-Elements 메인 설정 (커스텀 18개 규칙) |
| `karabiner_프리셋_windows_shortcuts.json` | rux616 Windows Shortcuts 프리셋 (63개) |
| `karabiner_내수동설정_백업_*.json` | 중간 백업 (참고용) |

---

## ✨ 핵심 기능

### 키보드
- **좌측 Option ↔ Command 스왑** (맥북 내장만, 외부 키보드는 그대로)
- **Ctrl+C/V/X/Z/A/T/W/N/S/F/...** 윈도우식 단축키 (터미널 자동 예외)
- **Windows 키 단축키**: Option+E (Finder) · Option+D (Mission Control) · Option+R (Spotlight) · Option+L (잠금) 등
- **Rectangle 창 분할**: Option+←/→/↑/↓
- **AltTab 창 전환**: 좌측 Cmd+Tab (윈도우 Alt+Tab)
- **한/영 전환**: 우측 Cmd + 외부 키보드 한/영 키 (모든 키보드 호환)
- **Cmd+F4** = 창 닫기 (Alt+F4 대응)
- **Ctrl+1~9** = 탭 이동
- **Ctrl + 클릭** = 새 탭으로 열기
- **Home/End/PgUp/PgDn** + **Ctrl+방향키** 단어 이동 + **Ctrl+Backspace** 단어 삭제

### 트랙패드 (자동 적용)
- 탭하여 클릭
- 세 손가락 드래그
- 자연 스크롤 끄기 (윈도우 방향)
- 속도 2.5x

### Finder (자동 적용)
- 숨김 파일 표시
- 경로 막대 표시
- 모든 확장자 표시

### 마우스
- Mos 로 외부 마우스만 별도 스크롤 처리 (트랙패드와 분리)
- Ctrl+클릭 → 새 탭으로 (Karabiner 매핑)

---

## 🔌 새 디바이스 자동 적용

저장소의 `karabiner.json` 은 `is_keyboard: true` / `is_pointing_device: true` 일반 조건을 사용. 따라서:

| 새 디바이스 | 자동 적용 여부 |
|---|---|
| 외부 USB 키보드 | ✅ 즉시 |
| 블루투스 키보드 | ✅ 즉시 |
| 외장 마우스 (USB / 블루투스) | ✅ 즉시 |
| 매직 트랙패드 | ✅ 즉시 |

추가 설정 불필요.

---

## 🚧 자동화의 한계

다음 항목은 **macOS 보안상 자동화 불가능**합니다:

1. **드라이버 확장 승인** (시스템 설정 → 보안 섹션의 [허용] 버튼)
2. **TCC 권한 토글** (입력 모니터링 / 손쉬운 사용 / 화면 기록)
3. **재부팅 후 권한 재확인**

`install.sh` 가 권한 창은 자동으로 띄워주지만 **클릭은 사용자가 직접** 해야 합니다.

---

## 📚 출처 / 참고

- **Karabiner-Elements**: https://karabiner-elements.pqrs.org/
- **rux616/karabiner-windows-mode**: https://github.com/rux616/karabiner-windows-mode (포함된 Windows Shortcuts 프리셋의 출처)
- **Rectangle**: https://rectangleapp.com/
- **AltTab**: https://alt-tab-macos.netlify.app/
- **Mos**: https://mos.caldis.me/

---

## 🔄 설정 동기화

이 저장소가 곧 단일 진실 소스(SoT). 변경 시:

```bash
cp ~/.config/karabiner/karabiner.json karabiner_백업_20260425.json
git add -A && git commit -m "설정 변경 메모" && git push
```

다른 맥에서 받기:
```bash
git pull && bash install.sh
```
