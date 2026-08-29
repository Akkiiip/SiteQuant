# WorkManager 2.7.0 uses Room 2.2.5 to create this generated database by
# reflection during AndroidX Startup. Room's bundled rules retain the class,
# but not its members; R8 must retain the no-argument constructor and the
# generated database methods it invokes during initialization.
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
