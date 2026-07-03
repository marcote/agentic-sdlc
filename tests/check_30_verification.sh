assert_file evals/rubric.md
for d in "Task success" "Tool use" "Trajectory" "Hallucination" "Response quality"; do
  assert_contains evals/rubric.md "$d"
done
assert_file evals/README.md
assert_file verification/verification-report.md
for s in "Coverage snapshot" "Output eval" "Trajectory eval" "UAT" "Verdicto"; do
  assert_contains verification/verification-report.md "$s"
done
assert_file verification/uat-checklist.md
assert_file verification/code-review-checklist.md
