# fixture: no canonical ```json``` block at all (malformed input)

This file has prose but no fenced json block, so the engine cannot extract a
canonical North Star. Every subcommand that loads it must exit 2 (error),
never conflate it with a schema-invalid (exit 1) answer.

Just prose. No block here.
