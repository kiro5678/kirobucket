# Problem Resolution Knowledge Base

This file is the repository-wide, mandatory knowledge base for technical problems encountered while maintaining `kirobucket`.

## Mandatory rule

Whenever a real problem is encountered in this repository, investigate it to an evidence-supported cause and apply a fix. **After the problem has been resolved, add an entry to this file in the same task.** Do not finish the task with a fix that exists only in chat, a commit message, or an unrecorded workflow run.

This rule applies to all repository work, not only Scoop manifests. Examples include manifests, Scoop behavior, PowerShell scripts, GitHub Actions, CI validation, release/download handling, documentation generation, repository structure, and maintenance tooling.

Before investigating a recurring or previously seen problem, search this knowledge base and reuse the recorded findings where they still apply. Update an existing entry when new evidence changes the cause, fix, or verification procedure; do not create duplicate entries for the same underlying issue.

## Required incident record

Each resolved issue must record:

1. **Date** — the date the issue was resolved (YYYY-MM-DD).
2. **Problem and symptoms** — what failed, the exact error or incorrect behavior, and the affected file, manifest, workflow, or component.
3. **Root cause** — the cause established by investigation. Distinguish confirmed facts from hypotheses; never present an assumption as a confirmed cause.
4. **Resolution** — the exact change or steps that fixed the problem, including relevant file paths and settings.
5. **Verification** — the checks actually performed and their results. Link to the relevant GitHub Actions run, commit, issue, release, or other evidence when available.
6. **Prevention / regression check** — the rule, test, validation, or monitoring step that prevents recurrence.
7. **Status** — use **Resolved and verified** only when the fix has been tested or independently confirmed. If verification is incomplete, say so explicitly and do not label the issue verified.

Do not claim that an entire workflow, manifest, installation, or batch passed when only one stage or a partial sample was checked. Record the exact scope of successful and unsuccessful checks.

## Incident entry template

Copy this template for every newly resolved issue and fill in the evidence-based details:

### YYYY-MM-DD — Short problem title

- **Status:** Resolved and verified / Resolved, verification pending
- **Affected area:** `path/to/file`, manifest name, workflow, or component
- **Problem:** Observable failure and relevant error/output.
- **Root cause:** Confirmed cause; explicitly mark any remaining uncertainty.
- **Resolution:** Exact change made and why it addresses the cause.
- **Verification:** Commands, tests, workflow run links, commit links, and precise results. State what was not tested.
- **Prevention:** New or updated rule, automated check, or procedure that prevents recurrence.

## Documentation and evidence rules

- Add the entry **after** resolving the problem and confirming the fix; do not wait for a later cleanup task.
- Keep entries concise but reproducible. Include exact paths, command names, workflow names, and relevant version details.
- Prefer links to immutable commit SHAs and specific GitHub Actions runs over links to moving branch pages.
- Preserve useful error text, but remove credentials, tokens, private URLs, personal paths, and other secrets.
- If several symptoms share one confirmed root cause, document them in one incident. If apparently similar failures have different causes, document them separately.
- If the cause is still unknown or the fix is not verified, do not invent a resolution. Record the limitation in the relevant task or issue and add the knowledge-base entry once the cause and fix are established.
- When a new incident exposes a general repository rule, update the relevant permanent guide (for example, `docs/manifest-authoring.md`) as well as adding the incident entry here.

## Resolved incidents

### 2026-10-31 — إصلاح تكرار وفساد دليل إنشاء المانيفستات ودمج قواعد قابلية النقل

- **الحالة:** تم الإصلاح والتحقق من تحديث التوثيق.
- **الملفات المتأثرة:** `docs/manifest-authoring.md`، `docs/manifest-portability.md`، `docs/scoop-manifest-portability-rules.md`.
- **المشكلة:** احتوى دليل إنشاء المانيفستات على مقطع قديم مكرر ومُدرج في منتصف فقرة `checkver.github`، ما قطع مثال Regex وكرر أجزاء من الدليل. كما كانت قواعد Portable / Nonportable موزعة في ملف منفصل مع روابط متقاطعة.
- **السبب الجذري:** السبب التاريخي لإدراج المقطع المكرر غير محسوم من محتوى الملفات وحده؛ المؤكد هو وجود التكرار وانقسام فقرة Regex. لا ننسب ذلك إلى Commit بعينه دون دليل.
- **الحل:** إعادة بناء `manifest-authoring.md` باللغة العربية كمرجع موحد، وحذف النسخة المكررة وإصلاح صياغة Regex، ودمج قواعد Portable / Nonportable وReview وطرق MSI وInno وNSIS وEXE والاختبارات في الدليل نفسه. تحديث رابط `manifest-portability.md` ليشير إلى الدليل الموحد، ثم حذف الملف المنفصل بعد نقل محتواه.
- **التحقق:** أُعيدت قراءة الدليل الموحد وجرد قابلية النقل من GitHub بعد التحديث، مع التحقق من المحتوى العربي والروابط الداخلية. لم تُشغّل اختبارات Scoop أو CI لأن التغييرات توثيقية.
- **الوقاية:** اعتماد `docs/manifest-authoring.md` كمرجع أساسي واحد، وعدم الاحتفاظ بنسخ قواعد متوازية. عند إضافة قاعدة جديدة، حدّث الدليل الموحد وجرد التصنيف وسجل المشكلة عند انطباق ذلك.


No incidents have been added to this knowledge base yet. Add the first entry when a repository problem has been fixed and its resolution has been verified.
