#!/sbin/sh
# 
# /system/addon.d/70-gapps.sh
#
. /tmp/backuptool.functions

list_files() {
cat <<EOF
app/GoogleCalendarSyncAdapter.apk
app/GoogleContactsSyncAdapter.apk
etc/default-permissions/default-permissions.xml
etc/default-permissions/opengapps-permissions.xml
etc/g.prop
etc/permissions/com.google.android.maps.xml
etc/permissions/com.google.android.media.effects.xml
etc/permissions/com.google.widevine.software.drm.xml
etc/permissions/privapp-permissions-google.xml
etc/preferred-apps/google.xml
etc/sysconfig/framework-sysconfig.xml
etc/sysconfig/google.xml
etc/sysconfig/google_build.xml
etc/sysconfig/whitelist_com.android.omadm.service.xml
framework/com.google.android.maps.jar
framework/com.google.android.media.effects.jar
framework/com.google.widevine.software.drm.jar
lib/libAppDataSearch.so
lib/libWhisper.so
lib/libconscrypt_gmscore_jni.so
lib/libcronet.63.0.3236.6.so
lib/libgcastv2_base.so
lib/libgcastv2_support.so
lib/libgmscore.so
lib/libgoogle-ocrclient-v3.so
lib/libjgcastservice.so
lib/libjni_latinimegoogle.so
lib/libleveldbjni.so
lib/libvcdiffjni.so
lib/libwearable-selector.so
priv-app/GoogleBackupTransport.apk
priv-app/GoogleFeedback.apk
priv-app/GoogleLoginService.apk
priv-app/GoogleOneTimeInitializer.apk
priv-app/GooglePartnerSetup.apk
priv-app/GoogleServicesFramework.apk
priv-app/Phonesky.apk
priv-app/PrebuiltGmsCore.apk
priv-app/SetupWizard.apk
EOF
}

# Backup/Restore using /sdcard if the installed GApps size plus a buffer for other addon.d backups (204800=200MB) is larger than /tmp
installed_gapps_size_kb=$(grep "^installed_gapps_size_kb" /tmp/gapps.prop | cut -d '=' -f 2)
if [ ! "$installed_gapps_size_kb" ]; then
  installed_gapps_size_kb="$(cd /system; size=0; for n in $(du -ak $(list_files) | cut -f 1); do size=$((size+n)); done; echo "$size")"
  echo "installed_gapps_size_kb=$installed_gapps_size_kb" >> /tmp/gapps.prop
fi

free_tmp_size_kb=$(grep "^free_tmp_size_kb" /tmp/gapps.prop | cut -d '=' -f 2)
if [ ! "$free_tmp_size_kb" ]; then
  free_tmp_size_kb="$(echo $(df -k /tmp | tail -n 1) | cut -d ' ' -f 4)"
  echo "free_tmp_size_kb=$free_tmp_size_kb" >> /tmp/gapps.prop
fi

buffer_size_kb=204800
if [ $((installed_gapps_size_kb + buffer_size_kb)) -ge "$free_tmp_size_kb" ]; then
  C=/sdcard/tmp-gapps
fi

case "$1" in
  backup)
    list_files | while read -r FILE DUMMY; do
      backup_file "$S"/"$FILE"
    done
  ;;
  restore)
    list_files | while read -r FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file "$S"/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Remove Stock/AOSP apps (from GApps Installer)
    rm -rf /system/priv-app/ExtServices.apk
    rm -rf /system/app/Provision.apk
    rm -rf /system/priv-app/Provision.apk

    # Remove 'other' apps (per installer.data)
    rm -rf /system/app/BooksStub.apk
    rm -rf /system/app/CalendarGoogle.apk
    rm -rf /system/app/CloudPrint.apk
    rm -rf /system/app/DeskClockGoogle.apk
    rm -rf /system/app/EditorsDocsStub.apk
    rm -rf /system/app/EditorsSheetsStub.apk
    rm -rf /system/app/EditorsSlidesStub.apk
    rm -rf /system/app/Gmail.apk
    rm -rf /system/app/Gmail2.apk
    rm -rf /system/app/GoogleCalendar.apk
    rm -rf /system/app/GoogleCloudPrint.apk
    rm -rf /system/app/GoogleHangouts.apk
    rm -rf /system/app/GoogleKeep.apk
    rm -rf /system/app/GoogleLatinIme.apk
    rm -rf /system/app/GooglePlus.apk
    rm -rf /system/app/Keep.apk
    rm -rf /system/app/NewsWeather.apk
    rm -rf /system/app/NewsstandStub.apk
    rm -rf /system/app/PartnerBookmarksProvider.apk
    rm -rf /system/app/PrebuiltBugleStub.apk
    rm -rf /system/app/PrebuiltKeepStub.apk
    rm -rf /system/app/QuickSearchBox.apk
    rm -rf /system/app/Vending.apk
    rm -rf /system/priv-app/GmsCore.apk
    rm -rf /system/priv-app/GmsCore_update.apk
    rm -rf /system/priv-app/GoogleHangouts.apk
    rm -rf /system/priv-app/GoogleNow.apk
    rm -rf /system/priv-app/GoogleSearch.apk
    rm -rf /system/priv-app/OneTimeInitializer.apk
    rm -rf /system/priv-app/QuickSearchBox.apk
    rm -rf /system/priv-app/Velvet_update.apk
    rm -rf /system/priv-app/Vending.apk

    # Remove 'priv-app' apps from 'app' (per installer.data)
    rm -rf /system/app/CanvasPackageInstaller.apk
    rm -rf /system/app/ConfigUpdater.apk
    rm -rf /system/app/GoogleBackupTransport.apk
    rm -rf /system/app/GoogleFeedback.apk
    rm -rf /system/app/GoogleLoginService.apk
    rm -rf /system/app/GoogleOneTimeInitializer.apk
    rm -rf /system/app/GooglePartnerSetup.apk
    rm -rf /system/app/GoogleServicesFramework.apk
    rm -rf /system/app/OneTimeInitializer.apk
    rm -rf /system/app/Phonesky.apk
    rm -rf /system/app/PrebuiltGmsCore.apk
    rm -rf /system/app/SetupWizard.apk
    rm -rf /system/app/Velvet.apk

    # Remove 'required' apps (per installer.data)
    rm -rf /system/lib/libjni_latinime.so
    rm -rf /system/lib/libjni_latinimegoogle.so

    # Remove 'user requested' apps (from gapps-config)

  ;;
  post-restore)
    # Recreate required symlinks (from GApps Installer)
    ln -sfn "/system/lib/libjni_latinimegoogle.so" "/system/lib/libjni_latinime.so"

    # Apply build.prop changes (from GApps Installer)
    sed -i "s/ro.error.receiver.system.apps=.*/ro.error.receiver.system.apps=com.google.android.gms/g" /system/build.prop

    # Re-pre-ODEX APKs (from GApps Installer)

    # Remove any empty folders we may have created during the removal process
    for i in /system/app /system/priv-app /system/vendor/pittpatt /system/usr/srec; do
      if [ -d $i ]; then
        find $i -type d -exec rmdir -p '{}' \+ 2>/dev/null;
      fi
    done;
    # Fix ownership/permissions and clean up after backup and restore from /sdcard
    find /system/vendor/pittpatt -type d -exec chown 0:2000 '{}' \; # Change pittpatt folders to root:shell per Google Factory Settings
    for i in $(list_files); do
      chown root:root "/system/$i"
      chmod 644 "/system/$i"
      chmod 755 "$(dirname "/system/$i")"
    done
    rm -rf /sdcard/tmp-gapps
  ;;
esac
