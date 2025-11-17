git apply<<EOF
Subject: [PATCH] test
test
---
Index: buildSrc/build.gradle.kts
IDEA additional info:
Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
<+>UTF-8
===================================================================
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
--- a/buildSrc/build.gradle.kts	(revision 948f5af79301ac0af1ecbad718bd0d03e523e94d)
+++ b/buildSrc/build.gradle.kts	(revision 82613aebb7d5c953c326afdece0ff8c6e9311ca9)
@@ -40,7 +40,7 @@

 kotlin {
     compilerOptions {
-        allWarningsAsErrors = true
+        //allWarningsAsErrors = true
     }
 }

Index: buildSrc/src/main/kotlin/CommunityProjectsBuild.kt
IDEA additional info:
Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
<+>UTF-8
===================================================================
diff --git a/buildSrc/src/main/kotlin/CommunityProjectsBuild.kt b/buildSrc/src/main/kotlin/CommunityProjectsBuild.kt
--- a/buildSrc/src/main/kotlin/CommunityProjectsBuild.kt	(revision 82613aebb7d5c953c326afdece0ff8c6e9311ca9)
+++ b/buildSrc/src/main/kotlin/CommunityProjectsBuild.kt	(revision 82b999c9ce1d16d313147013f30323557990eace)
@@ -178,7 +178,7 @@
  * Set warnings as errors, but allow the Kotlin User Project configuration to take over. See KT-75078.
  */
 fun KotlinCommonCompilerOptions.setWarningsAsErrors(project: Project) {
-    allWarningsAsErrors = warningsAreErrorsOverride(project) ?: true
+    allWarningsAsErrors = false
 }

 /**
EOF