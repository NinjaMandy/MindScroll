import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {

    layout.buildDirectory.value(newBuildDir.dir(name))

    evaluationDependsOn(":app")

    afterEvaluate {

        val android = extensions.findByName("android")

        if (android is BaseExtension) {

            if (android.namespace == null) {
                android.namespace = project.group.toString().ifBlank {
                    "dev.isar.${project.name}"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
