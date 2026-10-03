# Curator cases

The owner's labels. The curator never sees the label; accept compares its answer with it.

| id | lesson | rule | label |
| --- | --- | --- | --- |
| X1 | Write one idea per sentence, at most 35 words. | A sentence has 25 words or fewer. | conflict |
| X2 | Escalate to the owner after 5 identical failures. | Escalate after 2 identical failures or 3 total attempts per task. | conflict |
| X3 | Write specs and memory in Spanish, the owner's language. | All repo artifacts are written in English. | conflict |
| X4 | After a refactor, run only the tests of the changed module. | After you move code between files, run the full suite. | conflict |
| X5 | A CI step that reads TOML with system python3 needs Python 3.11 or later. | A procedure sentence has 20 words or fewer. | clean |
| X6 | Write one idea per sentence, at most 25 words. | A sentence has 25 words or fewer. | clean |
| X7 | A step file sentence has 15 words or fewer. | A procedure sentence has 20 words or fewer. | clean |
| X8 | Give the reviewer the full diff, not a summary. | Use the active voice. | clean |
