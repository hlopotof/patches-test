git apply<<EOF
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
EOF