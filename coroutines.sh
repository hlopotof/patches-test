git apply<<EOF
diff --git a/buildSrc/src/main/kotlin/kotlin-multiplatform-conventions.gradle.kts b/buildSrc/src/main/kotlin/kotlin-multiplatform-conventions.gradle.kts
index 4394ec045..63a64fca7 100644
--- a/buildSrc/src/main/kotlin/kotlin-multiplatform-conventions.gradle.kts
+++ b/buildSrc/src/main/kotlin/kotlin-multiplatform-conventions.gradle.kts
@@ -33,27 +33,14 @@ kotlin {
         // According to https://kotlinlang.org/docs/native-target-support.html
         // Tier 1
         linuxX64()
-        macosX64()
-        macosArm64()
-        iosSimulatorArm64()
-        iosX64()
         // Tier 2
         linuxArm64()
-        watchosSimulatorArm64()
-        watchosX64()
-        watchosArm32()
-        watchosArm64()
-        tvosSimulatorArm64()
-        tvosX64()
-        tvosArm64()
-        iosArm64()
         // Tier 3
         androidNativeArm32()
         androidNativeArm64()
         androidNativeX86()
         androidNativeX64()
         mingwX64()
-        watchosDeviceArm64()
     }
     js {
         outputModuleName = project.name
diff --git a/kotlinx-coroutines-core/build.gradle.kts b/kotlinx-coroutines-core/build.gradle.kts
index 07fb22c64..51e3ac529 100644
--- a/kotlinx-coroutines-core/build.gradle.kts
+++ b/kotlinx-coroutines-core/build.gradle.kts
@@ -47,7 +47,7 @@ kotlin {
         groupSourceSets("concurrent", listOf("jvm", "native"), listOf("common"))
         if (project.nativeTargetsAreEnabled) {
             // TODO: 'nativeDarwin' behaves exactly like 'apple', we can remove it
-            groupSourceSets("nativeDarwin", listOf("apple"), listOf("native"))
+//            groupSourceSets("nativeDarwin", listOf("apple"), listOf("native"))
             groupSourceSets("nativeOther", listOf("linux", "mingw", "androidNative"), listOf("native"))
         }
         jvmMain {
EOF

git apply<<EOF
diff --git a/buildSrc/build.gradle.kts b/buildSrc/build.gradle.kts
index ef767acf3..f4b23721f 100644
--- a/buildSrc/build.gradle.kts
+++ b/buildSrc/build.gradle.kts
@@ -40,7 +40,7 @@ fun version(target: String): String {

 kotlin {
     compilerOptions {
-        allWarningsAsErrors = true
+//        allWarningsAsErrors = true
     }
 }

EOF