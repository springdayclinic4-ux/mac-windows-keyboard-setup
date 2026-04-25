#!/usr/bin/env bash
# 맥북 윈도우식 키보드 설정 자동 설치
# 사용법: bash install.sh

set -e

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KARABINER_CFG="$HOME/.config/karabiner/karabiner.json"
KARABINER_PRESETS="$HOME/.config/karabiner/assets/complex_modifications"

color_info()  { printf "\033[1;34m[*]\033[0m %s\n" "$1"; }
color_ok()    { printf "\033[1;32m[✓]\033[0m %s\n" "$1"; }
color_warn()  { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }
color_step()  { printf "\n\033[1;36m=== %s ===\033[0m\n" "$1"; }

confirm() {
    local prompt="$1"
    read -rp "$(printf "\033[1;33m[?]\033[0m %s " "$prompt") (Enter 누르면 계속, Ctrl+C 중단) "
}

# ------------------------------------------------------------
color_step "1/7  Homebrew 확인"
if ! command -v brew >/dev/null 2>&1; then
    color_warn "Homebrew 미설치. 먼저 설치하세요:"
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi
color_ok "Homebrew $(brew --version | head -1)"

# ------------------------------------------------------------
color_step "2/7  필수 앱 설치 (Karabiner / Rectangle / AltTab / Mos)"
color_warn "Karabiner DriverKit 설치 시 비밀번호 입력 필요 (sudo)"
brew install --cask karabiner-elements rectangle alt-tab mos || true
color_ok "앱 설치 완료"

# ------------------------------------------------------------
color_step "3/7  Karabiner 설정 파일 + 외부 프리셋 복사"
mkdir -p "$KARABINER_PRESETS"
cp "$REPO_DIR/karabiner_백업_20260425.json" "$KARABINER_CFG"
cp "$REPO_DIR/karabiner_프리셋_windows_shortcuts.json" "$KARABINER_PRESETS/1777047574.json"
color_ok "설정: $KARABINER_CFG"
color_ok "프리셋: $KARABINER_PRESETS/1777047574.json"

# ------------------------------------------------------------
color_step "4/7  트랙패드 / Finder 기본 설정 적용"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write -g com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write -g com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"
killall Finder SystemUIServer 2>/dev/null || true
color_ok "트랙패드: 탭 클릭 / 세 손가락 드래그 / 자연 스크롤 끄기 / 속도 2.5x"
color_ok "Finder: 숨김 파일 / 경로 막대 / 확장자 표시"
color_ok "스크린샷 저장 위치: ~/Screenshots"

# ------------------------------------------------------------
color_step "5/7  Karabiner 실행"
open -a Karabiner-Elements 2>/dev/null || true
sleep 2

# Daemon 등록 트리거
if ! pgrep -l Karabiner-Core-Service >/dev/null 2>&1; then
    color_warn "Karabiner-Core-Service 미실행. Privileged Daemons 앱 실행 시도..."
    open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Privileged Daemons v2.app" 2>/dev/null || true
    open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents v2.app" 2>/dev/null || true
    sleep 3
fi

# ------------------------------------------------------------
color_step "6/7  ⚠️  드라이버 확장 활성화 (수동 필요)"
echo ""
echo "지금 시스템 설정 → 개인정보 보호 및 보안 창이 열립니다."
echo "맨 아래 '보안' 섹션의 [허용] 버튼을 클릭하세요 (Karabiner 드라이버 승인)."
echo "재부팅 안내가 뜨면 재부팅 후 이 스크립트를 다시 실행하세요."
echo ""
confirm "준비 됐으면"
open "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"

# ------------------------------------------------------------
color_step "7/7  권한 허용 (3종)"
echo ""
echo "각 권한 창이 순서대로 뜹니다. 해당 항목 토글을 ON으로:"
echo ""
echo "  A) 입력 모니터링 → Karabiner-Elements, Karabiner-Core-Service, karabiner_session_monitor"
echo "  B) 손쉬운 사용 → Karabiner-Elements, Rectangle, AltTab, Mos"
echo "  C) 화면 기록 → AltTab"
echo ""
confirm "이제 권한 창 띄울까요"

open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
sleep 2
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
sleep 2
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

# ------------------------------------------------------------
color_step "8/8  한국어 입력기 확인"
if defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -qi korean; then
    color_ok "한국어 입력기 등록됨"
else
    color_warn "한국어 입력기 미등록"
    echo "  시스템 설정 → 키보드 → 입력 소스 → '편집' → '+' → '한국어' → '2벌식' 추가하세요."
fi

# ------------------------------------------------------------
echo ""
color_step "✅ 설치 완료"
echo ""
echo "최종 점검:"
echo "  1. 위 권한들 모두 ON 했는지 확인"
echo "  2. (필요 시) 재부팅"
echo "  3. 브라우저에서 Ctrl+T 테스트 → 새 탭 열리면 성공"
echo ""
echo "문제 발생 시 INSTALL.md 의 '10. 흔한 함정 정리' 섹션 참조."
echo ""
echo "Karabiner 앱들 실행 상태:"
pgrep -l karabiner | sed 's/^/  /'
pgrep -l Karabiner | sed 's/^/  /'
pgrep -l Rectangle | sed 's/^/  /'
pgrep -l AltTab | sed 's/^/  /'
pgrep -l Mos | sed 's/^/  /'
