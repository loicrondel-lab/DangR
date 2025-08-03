import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.dangeralert.app',
  appName: 'Danger Alert',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  },
  plugins: {
    Geolocation: {
      permissions: ["location"]
    },
    PushNotifications: {
      presentationOptions: ["badge", "sound", "alert"]
    },
    LocalNotifications: {
      smallIcon: "ic_stat_icon_config_sample",
      iconColor: "#488AFF",
      sound: "beep.wav"
    }
  }
};

export default config;