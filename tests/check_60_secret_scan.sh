H=.claude/hooks/secret-scan.sh
assert_file "$H"
# --scan-text: secret present → exit 1
if printf 'AKIA1234567890ABCDEF\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "AWS key not detected"; else _pass "AWS key detected"; fi
if printf 'BEGIN RSA PRIVATE KEY\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "private key not detected"; else _pass "private key detected"; fi
if printf 'password = "hunter2"\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "password not detected"; else _pass "password detected"; fi
# --scan-text: clean text → exit 0
if printf 'hello world\n' | bash "$H" --scan-text >/dev/null 2>&1; then _pass "clean text passes"; else _fail "clean text wrongly flagged"; fi
# hook mode: non-commit command → silent exit 0
if printf '{"tool_input":{"command":"ls -la"}}' | bash "$H" >/dev/null 2>&1; then _pass "non-commit no-op"; else _fail "non-commit should exit 0"; fi
assert_file .claude/settings.json
assert_contains .claude/settings.json "secret-scan.sh"
