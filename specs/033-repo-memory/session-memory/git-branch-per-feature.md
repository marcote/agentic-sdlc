---
name: git-branch-per-feature
description: "Preferencia de git — rama por feature, luego merge a main"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3bcf4de8-833f-4ebd-a50c-3fcf13f7be84
---

El usuario trabaja con **rama por feature y después merge a `main`** (no commitea
features directo a `main`). Ej.: `003-wow-self-validation`.

**Why:** encaja con la convención del harness "un feature = un folder `specs/NNN-*`";
la rama espeja el folder.

**How to apply:** al empezar un feature, crear rama `NNN-<slug>` y commitear ahí
(incluido el design doc); mergear a `main` recién al cierre. No pushear/mergear sin que
lo pida. Relacionado: [[feature-003-wow-self-validation]].
