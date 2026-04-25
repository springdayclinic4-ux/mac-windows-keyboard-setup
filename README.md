# 맥북 윈도우식 키보드 설정 백업

윈도우 사용자가 맥으로 넘어와도 단축키 감각 그대로 쓸 수 있도록 한 Karabiner-Elements 설정 + 트랙패드/마우스 세팅 일체.

## 포함된 것

- **`맥_윈도우식_단축키_설정.md`** — 모든 단축키 매핑 + 권한 체크리스트 + 트러블슈팅 가이드
- **`karabiner_백업_20260425.json`** — Karabiner-Elements 설정 파일 (그대로 `~/.config/karabiner/karabiner.json` 자리에 복사)
- **`karabiner_프리셋_windows_shortcuts.json`** — `rux616/karabiner-windows-mode` 의 Windows Shortcuts 프리셋 (63개 규칙 백업)
- **`karabiner_내수동설정_백업_*.json`** — 중간 백업 (참고용)

## 새 맥에서 한 번에 복원

```bash
brew install --cask karabiner-elements rectangle alt-tab mos
mkdir -p ~/.config/karabiner/assets/complex_modifications
cp karabiner_백업_20260425.json ~/.config/karabiner/karabiner.json
cp karabiner_프리셋_windows_shortcuts.json ~/.config/karabiner/assets/complex_modifications/1777047574.json
open -a Karabiner-Elements
```

이후 `맥_윈도우식_단축키_설정.md` 의 권한 체크리스트 따라 시스템 권한 허용 + 재부팅.

## 설정 핵심

- 좌측 Option↔Command 스왑 (맥북 내장 키보드만)
- Ctrl 기반 윈도우 단축키 전체 (Ctrl+C/V/T/W/S/F/...)
- Windows 키 단축키 (Option+E=Finder, Option+D=Mission Control 등)
- Rectangle 창 분할 (Option+방향키)
- AltTab 창 전환 (Cmd+Tab)
- 한/영 전환 (우측 Cmd + 외부 키보드 한/영 키)
- 모든 신규 키보드/마우스 자동 적용

자세한 내용은 `맥_윈도우식_단축키_설정.md` 참조.
