for f in brief spec acceptance coverage plan tasks retro; do
  assert_file "specs/_template/$f.md"
done
assert_contains specs/_template/acceptance.md "Given"
assert_contains specs/_template/acceptance.md "When"
assert_contains specs/_template/acceptance.md "Then"
assert_contains specs/_template/coverage.md "Estado"
assert_contains specs/_template/coverage.md "🔴"
assert_contains specs/_template/coverage.md "\[given\]"
