#!/usr/bin/env bash
# 맥북 윈도우식 키보드 설정 자동 설치 (idempotent — 몇 번 다시 실행해도 안전)
# 사용법: bash install.sh

set -e

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KARABINER_CFG="$HOME/.config/karabiner/karabiner.json"
KARABINER_PRESETS="$HOME/.config/karabiner/assets/complex_modifications"

c_info()  { printf "\033[1;34m[*]\033[0m %s\n" "$1"; }
c_ok()    { printf "\033[1;32m[✓]\033[0m %s\n" "$1"; }
c_skip()  { printf "\033[1;90m[~]\033[0m %s (이미 됨, 건너뜀)\n" "$1"; }
c_warn()  { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }
c_step()  { printf "\n\033[1;36m=== %s ===\033[0m\n" "$1"; }

confirm() {
    read -rp "$(printf "\033[1;33m[?]\033[0m %s [Enter] " "$1")" _
}

app_installed() {
    [ -d "/Applications/$1" ]
}

permission_hint() {
    cat <<EOF

  ──────────────────────────────────────────────────────
  $1 창이 떴습니다. 다음 항목들의 토글을 ON 해주세요:
$2
  ──────────────────────────────────────────────────────
EOF
}

# ============================================================
c_step "1/8  Homebrew 확인"
if command -v brew >/dev/null 2>&1; then
    c_ok "Homebrew $(brew --version | head -1 | awk '{print $2}')"
else
    c_warn "Homebrew 미설치"
    echo '  먼저 실행: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

# ============================================================
c_step "2/8  필수 앱 4종 설치"
for app_pair in "karabiner-elements:Karabiner-Elements.app" "rectangle:Rectangle.app" "alt-tab:AltTab.app" "mos:Mos.app"; do
    cask="${app_pair%%:*}"
    app="${app_pair##*:}"
    if app_installed "$app"; then
        c_skip "$app"
    else
        c_info "$cask 설치 중..."
        if [ "$cask" = "karabiner-elements" ]; then
            c_warn "DriverKit 설치 시 비밀번호 입력 요구됨"
        fi
        brew install --cask "$cask" || c_warn "$cask 설치 실패 — 수동으로 다시 시도"
    fi
done

# ============================================================
c_step "3/8  Karabiner 설정 파일 + 외부 프리셋 복사"
mkdir -p "$KARABINER_PRESETS"
if [ -f "$KARABINER_CFG" ] && ! diff -q "$REPO_DIR/karabiner_백업_20260425.json" "$KARABINER_CFG" >/dev/null 2>&1; then
    backup="$KARABINER_CFG.before_install.$(date +%Y%m%d_%H%M%S)"
    cp "$KARABINER_CFG" "$backup"
    c_warn "기존 설정과 다름. 백업: $backup"
fi
cp "$REPO_DIR/karabiner_백업_20260425.json" "$KARABINER_CFG"
cp "$REPO_DIR/karabiner_프리셋_windows_shortcuts.json" "$KARABINER_PRESETS/1777047574.json"
c_ok "설정 / 프리셋 복사 완료"

# ============================================================
c_step "4/8  트랙패드 / Finder 기본 설정 적용"
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
c_ok "트랙패드: 탭 클릭 / 세 손가락 드래그 / 자연 스크롤 끄기 / 속도 2.5x"
c_ok "Finder: 숨김 파일 / 경로 막대 / 확장자 표시"

# ============================================================
c_step "5/8  Karabiner 실행 + Daemon 등록"
open -a Karabiner-Elements 2>/dev/null || true
sleep 2

if pgrep -l Karabiner-Core-Service >/dev/null 2>&1; then
    c_ok "Karabiner-Core-Service 실행 중"
else
    c_warn "Karabiner-Core-Service 미실행 — Privileged Daemons 앱 트리거"
    open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Privileged Daemons v2.app" 2>/dev/null || true
    open "/Library/Application Support/org.pqrs/Karabiner-Elements/Karabiner-Elements Non-Privileged Agents v2.app" 2>/dev/null || true
    sleep 3
fi

# Rectangle / AltTab / Mos 도 띄워둠 (권한 요청 트리거)
open -a Rectangle 2>/dev/null || true
open -a AltTab 2>/dev/null || true
open -a Mos 2>/dev/null || true

# ============================================================
c_step "6/8  ⚠️  드라이버 확장 활성화 (수동 — 시스템 보안 정책)"
if systemextensionsctl list 2>/dev/null | grep -q "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice.*activated enabled"; then
    c_ok "Karabiner 드라이버 확장 활성화됨"
else
    cat <<'EOF'

  ──────────────────────────────────────────────────────
  ⚠️ 가장 흔한 함정: 드라이버 확장 승인이 필요합니다.

  지금 시스템 설정 → 개인정보 보호 및 보안 창이 열립니다.
  스크롤을 맨 아래까지 내려서 "보안" 섹션 확인.
  "시스템 소프트웨어 'Fumiaki Takahashi' / 'pqrs.org' 차단됨"
  메시지 옆 [허용] 버튼 클릭 → 비밀번호 입력 → 재부팅 안내 시 재부팅.

  재부팅 후 이 스크립트(bash install.sh)를 다시 실행하세요.
  ──────────────────────────────────────────────────────
EOF
    open "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"
    confirm "위 안내 확인"
fi

# ============================================================
c_step "7/8  권한 허용 (입력 모니터링 / 손쉬운 사용 / 화면 기록)"
echo ""
permission_hint "입력 모니터링" "    - Karabiner-Elements
    - Karabiner-Core-Service ← 이게 안 보이면 6단계 재부팅 필요
    - karabiner_session_monitor"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
confirm "토글 켰으면"

permission_hint "손쉬운 사용" "    - Karabiner-Elements
    - Rectangle
    - AltTab
    - Mos"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
confirm "토글 켰으면"

permission_hint "화면 기록" "    - AltTab"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
confirm "토글 켰으면"

# ============================================================
c_step "8/8  한국어 입력기 확인"
if defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -qi "Korean.2SetKorean"; then
    c_ok "한국어 2벌식 등록됨"
else
    c_warn "한국어 입력기 미등록"
    echo "  시스템 설정 → 키보드 → 입력 소스 → 편집 → '+' → 한국어 → 2벌식"
    open "x-apple.systempreferences:com.apple.preference.keyboard?InputSources"
    confirm "추가했으면"
fi

# ============================================================
echo ""
c_step "✅ 설치 완료 — verify.sh 로 최종 점검"
echo ""
bash "$REPO_DIR/verify.sh"
