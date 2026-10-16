plugins {
    kotlin("multiplatform") version "2.2.21"
    kotlin("plugin.serialization") version "2.2.21"
    id("com.squareup.wire") version "5.1.0"
}

repositories {
    mavenCentral()
}

kotlin {
    macosX64("macosX64") {
        binaries.sharedLib {
            baseName = "news_core" 
        }
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                // Обновлено: Ktor 3.x стабилен и полностью поддерживает Kotlin 2.2+
                implementation("io.ktor:ktor-client-core:3.0.1")
                implementation("io.ktor:ktor-client-content-negotiation:3.0.1")
                implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.1")
                
                // Обновлено: Корутины, собранные под Kotlin 2.2+
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")
                
                implementation("com.squareup.wire:wire-runtime:5.1.0")
            }
        }
        
        val macosX64Main by getting {
            dependencies {
                // Обновлено: Дарвин-движок для Ktor 3.x
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