# North

These rules are first. They apply to every answer, design, spec and code change.

1. Use context engineering. Give each agent the context that its task needs. Then the agent does the task correctly.
2. Keep machine state as structured data with a schema: JSON, TOML or JUnit XML. Code reads fields.
3. Do not parse strings. Code never searches text for a pattern to get state or meaning. This rule has no exception for one sentence or one word.
4. A model with the correct context judges meaning. The owner decides what the model flags. A model never blocks alone.
5. Before the owner sees a design or a proposal, a fresh reviewer checks it against these rules.
6. The owner asked for ASD-STE100. Do not add a standard, a format or a framework that the owner did not ask for.
