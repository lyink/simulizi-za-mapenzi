package com.lyinkjr.kamusi

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    companion object {
        init {
            // Force Java DNS resolver to prefer IPv4 over IPv6.
            // This fixes Firestore gRPC "Unable to resolve host firestore.googleapis.com"
            // (EAI_NODATA) on Android devices where IPv6 DNS resolution fails.
            System.setProperty("java.net.preferIPv4Stack", "true")
            System.setProperty("java.net.preferIPv4Addresses", "true")
        }
    }
}
