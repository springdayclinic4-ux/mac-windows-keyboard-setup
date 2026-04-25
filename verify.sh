#!/usr/bin/env bash
# 설치 후 권한·실행 상태 자동 검증
# 사용법: bash verify.sh

KARABINER_CFG="$HOME/.config/karabiner/karabiner.json"
PASS=0
FAIL=0

ok()    { printf "  \033[1;32m✓\033[0m %s\n" "$1"; PASS=$((PASS+1)); }
fail()  { printf "  \033[1;31m✗\033[0m %s — %s\n" "$1" "$2"; FAIL=$((FAIL+1)); }

printf "\n\033[1;36m=== 설치 검증 ===\033[0m\n\n"

# ── 앱 설치 ─────────────────────────────────────
echo "[ 앱 설치 ]"
for app in "Karabiner-Elements.app" "Rectangle.app" "AltTab.app" "Mos.app"; do
    if [ -d "/Applications/$app" ]; then ok "$app"; else fail "$app" "/Applications에 없음 — brew install --cask 필요"; fi
done

# ── Karabiner 설정 파일 ─────────────────────────
echo ""
echo "[ Karabiner 설정 ]"
if [ -f "$KARABINER_CFG" ]; then
    if python3 -c "import json; json.load(open('$KARABINER_CFG'))" >/dev/null 2>&1; then
        rule_count=$(python3 -c "import json; print(len(json.load(open('$KARABINER_CFG'))['profiles'][0]['complex_modifications']['rules']))")
        ok "설정 파일 유효 (규칙 $rule_count 개)"
    else
        fail "설정 파일 손상" "JSON 파싱 실패 — install.sh 다시 실행"
    fi
else
    fail "설정 파일 없음" "$KARABINER_CFG — install.sh 실행 필요"
fi

if [ -f "$HOME/.config/karabiner/assets/complex_modifications/1777047574.json" ]; then
    ok "Windows Shortcuts 프리셋 설치됨"
else
    fail "Windows Shortcuts 프리셋 없음" "install.sh 다시 실행"
fi

# ── 드라이버 확장 ────────────────────────────────
echo ""
echo "[ 시스템 확장 / Daemon ]"
if systemextensionsctl list 2>/dev/null | grep -q "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice.*activated enabled"; then
    ok "Karabiner 드라이버 확장 활성화"
else
    fail "Karabiner 드라이버 확장 미활성" "시스템 설정 → 개인정보 보호 및 보안 → 보안 섹션 [허용] + 재부팅"
fi

# ── 핵심 프로세스 ────────────────────────────────
declare -a procs=("Karabiner-Core-Service" "Karabiner-VirtualHIDDevice-Daemon" "karabiner_console_user_server" "karabiner_session_monitor" "Karabiner-Elements")
for p in "${procs[@]}"; do
    if pgrep -lf "$p" >/dev/null 2>&1; then
        ok "$p 실행 중"
    else
        fail "$p 미실행" "Karabiner-Elements 재시작 필요"
    fi
done

# ── 보조 앱 ──────────────────────────────────────
echo ""
echo "[ 보조 앱 실행 ]"
for app in "Rectangle" "AltTab" "Mos"; do
    if pgrep -l "$app" >/dev/null 2>&1; then
        ok "$app 실행 중"
    else
        fail "$app 미실행" "open -a $app"
    fi
done

# ── 한국어 입력기 ────────────────────────────────
echo ""
echo "[ 입력기 ]"
if defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -qi "Korean.2SetKorean"; then
    ok "한국어 2벌식 등록됨"
else
    fail "한국어 2벌식 미등록" "시스템 설정 → 키보드 → 입력 소스에서 한국어 추가"
fi

# ── 트랙패드 / Finder 설정 ──────────────────────
echo ""
echo "[ 트랙패드 / Finder ]"
[ "$(defaults read com.apple.AppleMultitouchTrackpad Clicking 2>/dev/null)" = "1" ] && ok "탭하여 클릭 ON" || fail "탭하여 클릭 OFF" "재실행"
[ "$(defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag 2>/dev/null)" = "1" ] && ok "세 손가락 드래그 ON" || fail "세 손가락 드래그 OFF" "재실행"
[ "$(defaults read -g com.apple.swipescrolldirection 2>/dev/null)" = "0" ] && ok "자연 스크롤 OFF (윈도우 방향)" || fail "자연 스크롤 ON" "재실행"

# ── 결과 ────────────────────────────────────────
echo ""
printf "\033[1;36m=== 결과: \033[1;32m%d 통과\033[1;36m / \033[1;31m%d 실패\033[1;36m ===\033[0m\n\n" "$PASS" "$FAIL"

if [ "$FAIL" -eq 0 ]; then
    printf "\033[1;32m✅ 모든 항목 OK. 브라우저에서 Ctrl+T 눌러서 새 탭 열리는지 확인.\033[0m\n\n"
    exit 0
else
    printf "\033[1;33m⚠️ 위 [✗] 항목들의 해결 안내를 따르거나, INSTALL.md 의 '10. 흔한 함정 정리' 참조.\033[0m\n\n"
    exit 1
fi
