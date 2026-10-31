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

## 2026-10-31 — تصحيح توثيق مشغلات Manifest Pipeline

- **المشكلة:** وصف `docs/manifest-authoring.md` الـ Manifest Pipeline بأنه يدوي فقط، بينما ملف `.github/workflows/manifest-pipeline.yml` على `master` يعرّف أيضاً مشغّل `push` لفرع `master` عند تغيّر ملفات `bucket/*.json`. قد يؤدي هذا التعارض إلى توقع غير صحيح بشأن بدء التحقق بعد إضافة مانيفست.
- **الأعراض:** تعليمات الدليل لا تطابق إعدادات `on.push` و`on.workflow_dispatch` الفعلية في ملف Workflow.
- **السبب الجذري:** لم يُحدَّث وصف الدليل عند إضافة/تغيير مشغلات الـ Workflow؛ لذلك أصبح التوثيق قديماً.
- **الحل:** تعديل الدليل ليذكر المشغّل التلقائي عند دفع ملفات المانيفست إلى `master`، مع الإبقاء على إمكانية التشغيل اليدوي. إزالة الجملة الختامية القديمة التي كانت تزعم عدم وجود سجلات مشكلات رغم احتواء الملف على سجل سابق.
- **التحقق:** تمت قراءة YAML الحالي من `master` والتأكد من وجود `push.branches: master` و`push.paths: bucket/*.json` و`workflow_dispatch`. بعد التحديث ستتم إعادة قراءة ملفات التوثيق من GitHub للتحقق من انعكاس التعديل. لم يُشغَّل Workflow فعلياً ضمن هذا التصحيح.
- **الوقاية:** عند تعديل مشغلات أي Workflow، راجع القسم المقابل في `manifest-authoring.md` وحدثه في Commit نفسه. لا تعتبر قراءة YAML بديلاً عن متابعة تشغيل Actions.
- **الحالة:** تم تصحيح التوثيق والتحقق من مطابقته للإعداد الحالي؛ لم يُختبر تنفيذ Workflow.

## 2026-10-31 — تصحيح اكتشاف إصدارات Fig وNook عبر GitHub REST API

- **الحالة:** تم تعديل المانيفستات؛ تحقق Scoop بعد التصحيح لم يكتمل بعد.
- **الملفات المتأثرة:** `bucket/fig.json` و`bucket/nook.json`.
- **المشكلة:** فشل Fig في مطابقة Regex مع صفحة `https://github.com/Skynse/Fig/releases/latest`، فتوقف Manifest Pipeline قبل الوصول إلى Nook.
- **السبب الجذري:** Regex صُمم لالتقاط قيمة `tag_name` من JSON، لكن مصدر الفحص لم يقدّم JSON بالطريقة التي يتوقعها Scoop.
- **الحل:** استخدام `checkver.url` مع `jsonpath: "$.tag_name"` وRegex صريح في Fig وNook، مع توجيه URL إلى GitHub REST API الخاص بالإصدار الأحدث.
- **التحقق:** القيم الحالية عبر API هي Fig = `v1.0.1` وNook = `v0.2.1`. طابقت أنماط Regex هاتين القيمتين، لكن فحص Scoop المستقل للمانيفستين لم يُعَد تشغيله بعد.
- **الوقاية:** عند التقاط `tag_name` من JSON، استخدم `checkver.url` مع JSONPath وRegex؛ لا تفترض أن `checkver.github` أو صفحة GitHub العادية ستتحول تلقائياً إلى JSON.



## 2026-10-31 — إصلاح رابط أرشيف Android DEX والتحقق من مسارات التشغيل

- **الحالة:** تم الإصلاح والتحقق من جميع مراحل التحقق الخاصة بالمانيفست؛ تشغيل Manifest Pipeline المجمع ما زال ينتظر مرحلة تحديث صفحات README.
- **الملفات المتأثرة:** `bucket/android-dex.json` و`docs/manifest-authoring.md`.
- **المشكلة:** فشل فحص الأرشيف أولاً لأن `Android_Dex_Windows_x64.zip` لم يحتوِ على `Android_Dex.exe` في المسار المتوقع. بعد اختيار الأرشيف الرسمي الصحيح، كشف الفحص أن رابط التنزيل الحالي يحتوي المتغير غير المحلول `$version`.
- **السبب الجذري:** تم اختيار Asset غير مطابق لملف Windows الذي يوصي به README الرسمي، كما استُخدم متغير التحديث `$version` في رابط الإصدار الحالي بدلاً من وضعه في قالب `autoupdate` فقط.
- **الحل:** استخدام `Android_Dex_Windows.zip` من إصدار `Android-Dex-v.1.4` مع SHA-256 الصحيح، وجعل `architecture.64bit.url` رابطاً ثابتاً للإصدار الحالي. بقي `$version` في `autoupdate.architecture.64bit.url` فقط.
- **التحقق:** التنسيق نجح في [41193383683](https://github.com/kiro5678/kirobucket/actions/runs/41193383683). فحص `checkver` نجح في PowerShell وpwsh ضمن [41193419418](https://github.com/kiro5678/kirobucket/actions/runs/41193419418). فحص SHA-256 ومسارات الأرشيف نجح في [41193462723](https://github.com/kiro5678/kirobucket/actions/runs/41193462723). اختبار `autoupdate` نجح في [41193496154](https://github.com/kiro5678/kirobucket/actions/runs/41193496154)، واختبارات CI نجحت في PowerShell وpwsh ضمن [41193538127](https://github.com/kiro5678/kirobucket/actions/runs/41193538127). لا يُسجَّل تشغيل Manifest Pipeline المجمع كاملاً على أنه ناجح قبل انتهاء مرحلة تحديث جدول README.
- **الوقاية:** ضع رابط إصدار حقيقياً ومحدداً في `architecture.<arch>.url`. استخدم `$version` في قوالب `autoupdate.url` فقط، ثم افحص استخراج الأرشيف ووجود كل ملف في `bin` والاختصارات.



## 2026-10-31 — فشل Checkout لمستودع Scoop بسبب حد GitHub API

- **الحالة:** تم تطبيق إصلاح إعداد المصادقة؛ التحقق التشغيلي بعد التعديل ما زال معلقاً.
- **الملفات المتأثرة:** `.github/workflows/scoop-checkver-validation.yml` و`.github/workflows/ci.yml` و`.github/workflows/scoop-autoupdate-validation.yml`.
- **المشكلة:** فشلت وظائف Checkver وCI أثناء خطوة `Checkout Scoop` قبل تشغيل فحوص المانيفست، وظهر الخطأ الصريح `API rate limit exceeded for installation`. أدى ذلك إلى توقف Manifest Pipeline عند أول مرحلة فرعية فاشلة، وبالتالي لم تكتمل دفعة الـ48 ولا إعادة فحص Fig/Nook.
- **السبب الجذري:** كانت خطوة `actions/checkout` لمستودع `ScoopInstaller/Scoop` تستخدم تلقائياً `github.token` المرتبط بتثبيت GitHub App، ووصل هذا الرمز إلى حد طلبات API. السجلات تؤكد أن الفشل حدث أثناء Checkout وليس داخل Scoop `checkver` أو في Regex المانيفستات.
- **الحل:** أضيف إلى Checkout لمستودع Scoop في workflows الثلاثة الرمز `${{ secrets.CHECKVER_GITHUB_TOKEN || github.token }}`، بحيث يستخدم PAT المخزن في `CHECKVER_GITHUB_TOKEN` عند توفره، مع الإبقاء على رمز GitHub الافتراضي كخيار احتياطي.
- **التحقق:** تأكدت من سجلات التشغيل [41194974061](https://github.com/kiro5678/kirobucket/actions/runs/41194974061) و[41194857644](https://github.com/kiro5678/kirobucket/actions/runs/41194857644) أن Checkout Scoop انتهى برسالة حد API قبل تشغيل Checkver/CI. تم فحص التعديلات نصياً قبل دفعها؛ لم يُعَد تشغيل الوظائف بعد، لذا لا يُعد تجاوز حد API مثبتاً بعد.
- **الوقاية:** استخدم رمزاً مخصصاً ذا حد API مستقل عند Checkout لمستودع Scoop أو طلب GitHub API بكثافة. لا تسجل فشل Checkver على أنه خطأ مانيفست إذا فشلت خطوة Checkout قبل تشغيله. افصل نتيجة تجهيز بيئة الاختبار عن نتيجة الاختبار الفعلي في تقارير Manifest Pipeline.
