allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Force a stable Razorpay checkout version that bundles RzpAssist correctly.
    // Versions 1.6.27+ moved RzpAssist to a separate artifact that is not on Maven Central.
    configurations.all {
        resolutionStrategy {
            force("com.razorpay:checkout:1.6.26")
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
