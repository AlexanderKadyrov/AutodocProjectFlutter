plugins {
    kotlin("multiplatform") version "2.2.21"
    kotlin("plugin.serialization") version "2.2.21"
    id("com.squareup.wire") version "5.1.0"
}

repositories {
    mavenCentral()
}

kotlin {
    linuxX64("linuxX64") {
        binaries.sharedLib {
            baseName = "news_core" 
        }
    }

    macosX64("macosX64") {
        binaries.sharedLib {
            baseName = "news_core" 
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-core:3.0.1")
                implementation("io.ktor:ktor-client-content-negotiation:3.0.1")
                implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.1")
                implementation("com.squareup.wire:wire-runtime:5.1.0")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.0")
            }
        }

        val linuxX64Main by getting {
            dependencies {
                implementation("io.ktor:ktor-client-cio:3.0.1")
            }
        }
        
        val macosX64Main by getting {
            dependencies {
                implementation("io.ktor:ktor-client-darwin:3.0.1")
            }
        }
    }
}

wire {
    sourcePath("../proto")
    kotlin {
        android = false
    }
}