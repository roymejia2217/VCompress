allprojects {
    repositories {
        google()
        mavenCentral()
    }

    configurations.all {
        exclude(group = "com.google.android.play", module = "core")
        exclude(group = "com.google.android.play", module = "core-ktx")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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

// Arreglo para plugins antiguos sin namespace (p.ej. saf 1.0.3+4)
// Establece el namespace basado en el package del AndroidManifest del plugin
subprojects {
	if (name == "saf") {
		plugins.withId("com.android.library") {
			extensions.configure<com.android.build.gradle.LibraryExtension> {
				namespace = "com.ivehement.saf"
			}
		}
	}
}
