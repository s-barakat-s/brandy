import com.android.build.gradle.LibraryExtension
import org.gradle.api.Project

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            if (namespace == null) {
                namespace = project.fallbackNamespace()
            }
        }
    }
}

fun Project.fallbackNamespace(): String {
    val sanitizedGroup = group.toString()
        .ifBlank { "dev.flutter" }
        .replace(Regex("[^A-Za-z0-9_.]"), "_")
        .trim('.');

    val sanitizedName = name.replace(Regex("[^A-Za-z0-9_]"), "_")

    return if (sanitizedGroup.isBlank()) {
        "dev.flutter.$sanitizedName"
    } else {
        "$sanitizedGroup.$sanitizedName"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
