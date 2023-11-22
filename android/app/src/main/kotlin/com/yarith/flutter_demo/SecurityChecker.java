package com.yarith.flutter_demo;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Debug;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;


public class SecurityChecker {

    // Debug flag in AndroidManifest.xml
    public static boolean isDebuggable(Context context) {
        return ((context.getApplicationContext().getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0);
    }

    // Debug of Android Studio
    public static boolean detectDebugger() {
        return Debug.isDebuggerConnected();
    }

    static boolean detect_threadCpuTimeNanos() {
        long start = Debug.threadCpuTimeNanos();

        for (int i = 0; i < 1000000; ++i) continue;

        long stop = Debug.threadCpuTimeNanos();

        return stop - start >= 10000000;
    }

    private static String tracerpid = "TracerPid";

    public static boolean hasTracerPid() throws IOException {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(new FileInputStream("/proc/self/status")), 1000);
            String line;

            while ((line = reader.readLine()) != null) {
                if (line.length() > tracerpid.length()) {
                    if (line.substring(0, tracerpid.length()).equalsIgnoreCase(tracerpid)) {
                        if (Integer.decode(line.substring(tracerpid.length() + 1).trim()) > 0) {
                            return true;
                        }
                        break;
                    }
                }
            }

        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            reader.close();
        }
        return false;
    }
}

