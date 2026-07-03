assert_file docs/factory-model.md
assert_file docs/workflow.md
assert_file README.md
assert_contains README.md "constitution"
assert_contains README.md "coverage"
assert_file .github/workflows/verify.yml
assert_contains .github/workflows/verify.yml "tests/run.sh"
