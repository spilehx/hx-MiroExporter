package miroexporter.interactive;

import haxe.Timer;
import haxe.ds.StringMap;
import sys.thread.Mutex;
import sys.thread.Thread;

class InteractiveSessionTracker {
    private static final HEARTBEAT_TIMEOUT_SECONDS:Float = 15.0;
    private static final NO_SESSION_SHUTDOWN_DELAY_SECONDS:Float = 10.0;
    private static final STARTUP_GRACE_PERIOD_SECONDS:Float = 30.0;
    private static final WATCHDOG_POLL_INTERVAL_SECONDS:Float = 2.0;

    private static var activeSessions:StringMap<Float> = new StringMap<Float>();
    private static var mutex:Mutex = new Mutex();
    private static var startupTimestamp:Float = 0.0;
    private static var lastActiveSessionTimestamp:Float = 0.0;
    private static var watchdogStarted:Bool = false;

    public static function startWatchdog():Void {
        mutex.acquire();

        if (watchdogStarted) {
            mutex.release();
            return;
        }

        startupTimestamp = Timer.stamp();
        lastActiveSessionTimestamp = startupTimestamp;
        watchdogStarted = true;
        mutex.release();

        Thread.create(function() {
            while (true) {
                Sys.sleep(WATCHDOG_POLL_INTERVAL_SECONDS);

                if (shouldShutDownApplication()) {
                    USER_MESSAGE_INFO("No interactive browser sessions remain. Exiting application.");
                    Sys.exit(0);
                }
            }
        });
    }

    public static function recordHeartbeat(sessionId:String):Void {
        var now:Float;

        if (sessionId == null || sessionId == "") {
            return;
        }

        now = Timer.stamp();

        mutex.acquire();
        activeSessions.set(sessionId, now);
        lastActiveSessionTimestamp = now;
        mutex.release();
    }

    public static function disconnectSession(sessionId:String):Void {
        if (sessionId == null || sessionId == "") {
            return;
        }

        mutex.acquire();
        activeSessions.remove(sessionId);
        mutex.release();
    }

    private static function shouldShutDownApplication():Bool {
        var activeSessionCount:Int;
        var now:Float;
        var shouldShutDown:Bool;

        now = Timer.stamp();

        mutex.acquire();
        pruneExpiredSessions(now);
        activeSessionCount = countActiveSessions();

        if (activeSessionCount > 0) {
            lastActiveSessionTimestamp = now;
            mutex.release();
            return false;
        }

        if (now - startupTimestamp < STARTUP_GRACE_PERIOD_SECONDS) {
            mutex.release();
            return false;
        }

        shouldShutDown = now - lastActiveSessionTimestamp >= NO_SESSION_SHUTDOWN_DELAY_SECONDS;
        mutex.release();
        return shouldShutDown;
    }

    private static function pruneExpiredSessions(now:Float):Void {
        var expiredSessionIds:Array<String>;
        var lastSeenTimestamp:Null<Float>;
        var sessionId:String;

        expiredSessionIds = [];

        for (sessionId in activeSessions.keys()) {
            lastSeenTimestamp = activeSessions.get(sessionId);

            if (lastSeenTimestamp == null) {
                expiredSessionIds.push(sessionId);
                continue;
            }

            if (now - lastSeenTimestamp > HEARTBEAT_TIMEOUT_SECONDS) {
                expiredSessionIds.push(sessionId);
            }
        }

        for (sessionId in expiredSessionIds) {
            activeSessions.remove(sessionId);
        }
    }

    private static function countActiveSessions():Int {
        var count:Int;
        var sessionId:String;

        count = 0;

        for (sessionId in activeSessions.keys()) {
            count++;
        }

        return count;
    }
}
