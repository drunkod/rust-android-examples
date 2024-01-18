package co.realfit.agdkeframe;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.google.androidgamesdk.GameActivity;

import android.os.Bundle;
import android.content.pm.PackageManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;

import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.util.Log;

public class MainActivity extends GameActivity {

    private String textBoxString;

    static {
        // Load the STL first to workaround issues on old Android versions:
        // "if your app targets a version of Android earlier than Android 4.3
        // (Android API level 18),
        // and you use libc++_shared.so, you must load the shared library before any other
        // library that depends on it."
        // See https://developer.android.com/ndk/guides/cpp-support#shared_runtimes
        System.loadLibrary("c++_shared");
        // not use when export OPENSSL_STATIC=1
        // System.loadLibrary("crypto");
        // System.loadLibrary("ssl");
        // System.loadLibrary("gstfallbackswitch");
        System.loadLibrary("gstreamer_android");
        
        // Load the native library.
        // The name "android-game" depends on your CMake configuration, must be
        // consistent here and inside AndroidManifect.xml
        System.loadLibrary("main");
        
        // mnb

    }

    private void hideSystemUI() {
        // This will put the game behind any cutouts and waterfalls on devices which have
        // them, so the corresponding insets will be non-zero.
        if (VERSION.SDK_INT >= VERSION_CODES.P) {
            getWindow().getAttributes().layoutInDisplayCutoutMode
                    = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS;
        }
        // From API 30 onwards, this is the recommended way to hide the system UI, rather than
        // using View.setSystemUiVisibility.
        View decorView = getWindow().getDecorView();
        WindowInsetsControllerCompat controller = new WindowInsetsControllerCompat(getWindow(),
                decorView);
        controller.hide(WindowInsetsCompat.Type.systemBars());
        controller.hide(WindowInsetsCompat.Type.displayCutout());
        controller.setSystemBarsBehavior(
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
    }

  
    private void printCodecsNamed() {
            int numCodecs = MediaCodecList.getCodecCount();
            textBoxString = "Total Number of Codecs are : " + numCodecs + "\n";

            for (int i = 0; i < numCodecs; i++) {
                MediaCodecInfo codecInfo = MediaCodecList.getCodecInfoAt(i);
                textBoxString += "\n\nCodec : " + i + " ( " + (codecInfo.isEncoder() ? "Encoder" : "Decoder") + ")\nName: " + codecInfo.getName() + "\nTypes : ( ";

                String[] types = codecInfo.getSupportedTypes();
                textBoxString += types.length + " )";
                for (int j = 0; j < types.length; j++) {
                    textBoxString += "\n For Type : " + types[j] + " \n Color Formats: ";
                    VCNameResolver codecNames = new VCNameResolver(types[j]);
                    MediaCodecInfo.CodecCapabilities capabilities = codecInfo.getCapabilitiesForType(types[j]);
                    for (int k = 0; k < capabilities.colorFormats.length; k++) {
                        String colorName = codecNames.getColorName(capabilities.colorFormats[k]);
                        colorName = (colorName == null) ? capabilities.colorFormats[k] + "" : colorName;
                        textBoxString += "\n\t" + colorName + ",";
                    }
                    textBoxString += "\n";
                    for (int k = 0; k < capabilities.profileLevels.length; k++) {
                        String profileName = codecNames.getProfileName(capabilities.profileLevels[k].profile);
                        profileName = (profileName == null) ? capabilities.profileLevels[k].profile + "" : profileName;

                        String levelName = codecNames.getLevelName(capabilities.profileLevels[k].level);
                        levelName = (levelName == null) ? capabilities.profileLevels[k].level + "" : levelName;

                        textBoxString += "Profile: " + profileName
                                + ", Level: " + levelName + "\n";
                    }
                    textBoxString += "Maximum Instances: " + capabilities.getMaxSupportedInstances() + "\n";
                }
            }
            // textBox.setText(textBoxString);
            // writeToFile(textBoxString);
            Log.d("agdkeframe", "agdkeframe Variable value: " + textBoxString);
        }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // When true, the app will fit inside any system UI windows.
        // When false, we render behind any system UI windows.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        hideSystemUI();
        printCodecsNamed();
        // You can set IME fields here or in native code using GameActivity_setImeEditorInfoFields.
        // We set the fields in native_engine.cpp.
        // super.setImeEditorInfoFields(InputType.TYPE_CLASS_TEXT,
        //     IME_ACTION_NONE, IME_FLAG_NO_FULLSCREEN );
        super.onCreate(savedInstanceState);

            // Hide the action bar to fix touch screen bug
        if (getSupportActionBar() != null) {
            getSupportActionBar().hide();
        }
    }

    public boolean isGooglePlayGames() {
        PackageManager pm = getPackageManager();
        return pm.hasSystemFeature("com.google.android.play.feature.HPE_EXPERIENCE");
    }


        private static enum CodecDetail {
        CODEC_DETAIL_LEVEL, CODEC_DETAIL_PROFILE, CODEC_DETAIL_COLOR;
    }

    private abstract class NameResolver {
        private int id;
        private String name;
        private CodecDetail detail;

        public NameResolver(int id, String name, CodecDetail detail) {
            this.id = id;
            this.name = name;
            this.detail = detail;
        }

        public String getName() {
            return name;
        }

        public int getId() {
            return id;
        }

        public CodecDetail getCodecDetailType() {
            return detail;
        }
    }

    private class BaseProfileName extends NameResolver {

        public BaseProfileName(int id, String name) {
            super(id, name, CodecDetail.CODEC_DETAIL_PROFILE);
        }
    }

    private class BaseLevelName extends NameResolver {

        public BaseLevelName(int id, String name) {
            super(id, name, CodecDetail.CODEC_DETAIL_LEVEL);
        }
    }

    private class BaseColorName extends NameResolver {
        public BaseColorName(int id, String name) {
            super(id, name, CodecDetail.CODEC_DETAIL_COLOR);
        }
    }

    private final class BaseProfile {
        private String type;

        private BaseProfileName[] profiles;

        public BaseProfile(String type, BaseProfileName[] profiles) {
            this.type = type;
            this.profiles = profiles;
        }

        public String getType() {
            return type;
        }

        public String getName(int id) {
            for (BaseProfileName profile : profiles) {
                if (profile.getId() == id) {
                    return profile.getName();
                }
            }
            return null;
        }
    }

    private final class BaseLevel {
        private String type;
        private BaseLevelName[] levels;

        public BaseLevel(String type, BaseLevelName[] levels) {
            this.type = type;
            this.levels = levels;
        }

        public String getType() {
            return type;
        }

        public String getName(int id) {
            for (BaseLevelName level : levels) {
                if (level.getId() == id) {
                    return level.getName();
                }
            }
            return null;
        }
    }

    private final class BaseColor {
        private BaseColorName[] colors;

        public BaseColor(BaseColorName[] colors) {
            this.colors = colors;
        }

        public String getName(int id) {
            for (BaseColorName color : colors) {
                if (color.getId() == id) {
                    return color.getName();
                }
            }
            return null;
        }
    }

    private class VCNameResolver {
        String type;

        BaseProfile[] profiles = new BaseProfile[]{
                new BaseProfile("video/avc", new BaseProfileName[]
                        {
                                new BaseProfileName(1, "AVCProfileBaseline"),
                                new BaseProfileName(2, "AVCProfileMain"),
                                new BaseProfileName(4, "AVCProfileExtended"),
                                new BaseProfileName(8, "AVCProfileHigh"),
                                new BaseProfileName(16, "AVCProfileHigh10"),
                                new BaseProfileName(32, "AVCProfileHigh422"),
                                new BaseProfileName(64, "AVCProfileHigh444")
                        }),
                new BaseProfile("video/3gpp", new BaseProfileName[]
                        {
                                new BaseProfileName(1, "H263ProfileBaseline"),
                                new BaseProfileName(2, "H263ProfileH320Coding"),
                                new BaseProfileName(4, "H263ProfileBackwardCompatible"),
                                new BaseProfileName(8, "H263ProfileISWV2"),
                                new BaseProfileName(16, "H263ProfileISWV3"),
                                new BaseProfileName(32, "H263ProfileHighCompression"),
                                new BaseProfileName(64, "H263ProfileInternet"),
                                new BaseProfileName(128, "H263ProfileInterlace"),
                                new BaseProfileName(256, "H263ProfileHighLatency")
                        }),
                new BaseProfile("video/mp4v-es", new BaseProfileName[]
                        {
                                new BaseProfileName(1, "MPEG4ProfileSimple"),
                                new BaseProfileName(2, "MPEG4ProfileSimpleScalable"),
                                new BaseProfileName(4, "MPEG4ProfileCore"),
                                new BaseProfileName(8, "MPEG4ProfileMain"),
                                new BaseProfileName(16, "MPEG4ProfileNbit"),
                                new BaseProfileName(32, "MPEG4ProfileScalableTexture"),
                                new BaseProfileName(64, "MPEG4ProfileSimpleFace"),
                                new BaseProfileName(128, "MPEG4ProfileSimpleFBA"),
                                new BaseProfileName(256, "MPEG4ProfileBasicAnimated"),
                                new BaseProfileName(512, "MPEG4ProfileHybrid"),
                                new BaseProfileName(1024, "MPEG4ProfileAdvancedRealTime"),
                                new BaseProfileName(2048, "MPEG4ProfileCoreScalable"),
                                new BaseProfileName(4096, "MPEG4ProfileAdvancedCoding"),
                                new BaseProfileName(8192, "MPEG4ProfileAdvancedCore"),
                                new BaseProfileName(16384, "MPEG4ProfileAdvancedScalable"),
                                new BaseProfileName(32768, "MPEG4ProfileAdvancedSimple")
                        }),
                new BaseProfile("video/x-vnd.on2.vp8", new BaseProfileName[]
                        {
                                new BaseProfileName(1, "VP8ProfileMain")
                        })
        };

        BaseLevel[] levels = new BaseLevel[]{
                new BaseLevel("video/avc", new BaseLevelName[]
                        {
                                new BaseLevelName(1, "AVCLevel1"),
                                new BaseLevelName(2, "AVCLevel1b"),
                                new BaseLevelName(4, "AVCLevel11"),
                                new BaseLevelName(8, "AVCLevel12"),
                                new BaseLevelName(16, "AVCLevel13"),
                                new BaseLevelName(32, "AVCLevel2"),
                                new BaseLevelName(64, "AVCLevel21"),
                                new BaseLevelName(128, "AVCLevel22"),
                                new BaseLevelName(256, "AVCLevel3"),
                                new BaseLevelName(512, "AVCLevel31"),
                                new BaseLevelName(1024, "AVCLevel32"),
                                new BaseLevelName(2048, "AVCLevel4"),
                                new BaseLevelName(4096, "AVCLevel41"),
                                new BaseLevelName(8192, "AVCLevel42"),
                                new BaseLevelName(16384, "AVCLevel5"),
                                new BaseLevelName(32768, "AVCLevel51")
                        }),
                new BaseLevel("video/3gpp", new BaseLevelName[]
                        {
                                new BaseLevelName(1, "H263Level10"),
                                new BaseLevelName(2, "H263Level20"),
                                new BaseLevelName(4, "H263Level30"),
                                new BaseLevelName(8, "H263Level40"),
                                new BaseLevelName(16, "H263Level45"),
                                new BaseLevelName(32, "H263Level50"),
                                new BaseLevelName(64, "H263Level60"),
                                new BaseLevelName(128, "H263Level70")
                        }),
                new BaseLevel("video/mp4v-es", new BaseLevelName[]
                        {
                                new BaseLevelName(1, "MPEG4Level0"),
                                new BaseLevelName(2, "MPEG4Level0b"),
                                new BaseLevelName(4, "MPEG4Level1"),
                                new BaseLevelName(8, "MPEG4Level2"),
                                new BaseLevelName(16, "MPEG4Level3"),
                                new BaseLevelName(32, "MPEG4Level4"),
                                new BaseLevelName(64, "MPEG4Level4a"),
                                new BaseLevelName(128, "MPEG4Level5")
                        }),
                new BaseLevel("video/x-vnd.on2.vp8", new BaseLevelName[]
                        {
                                new BaseLevelName(1, "VP8Level_Version0"),
                                new BaseLevelName(2, "VP8Level_Version1"),
                                new BaseLevelName(4, "VP8Level_Version2"),
                                new BaseLevelName(8, "VP8Level_Version3")
                        })
        };

        BaseColor colors = new BaseColor(new BaseColorName[]
                {
                        new BaseColorName(1, "COLOR_FormatMonochrome"),
                        new BaseColorName(2, "COLOR_Format8bitRGB332"),
                        new BaseColorName(3, "COLOR_Format12bitRGB444"),
                        new BaseColorName(4, "COLOR_Format16bitARGB4444"),
                        new BaseColorName(5, "COLOR_Format16bitARGB1555"),
                        new BaseColorName(6, "COLOR_Format16bitRGB565"),
                        new BaseColorName(7, "COLOR_Format16bitBGR565"),
                        new BaseColorName(8, "COLOR_Format18bitRGB666"),
                        new BaseColorName(9, "COLOR_Format18bitARGB1665"),
                        new BaseColorName(10, "COLOR_Format19bitARGB1666"),
                        new BaseColorName(11, "COLOR_Format24bitRGB888"),
                        new BaseColorName(12, "COLOR_Format24bitBGR888"),
                        new BaseColorName(13, "COLOR_Format24bitARGB1887"),
                        new BaseColorName(14, "COLOR_Format25bitARGB1888"),
                        new BaseColorName(15, "COLOR_Format32bitBGRA8888"),
                        new BaseColorName(16, "COLOR_Format32bitARGB8888"),
                        new BaseColorName(17, "COLOR_FormatYUV411Planar"),
                        new BaseColorName(18, "COLOR_FormatYUV411PackedPlanar"),
                        new BaseColorName(19, "COLOR_FormatYUV420Planar"),
                        new BaseColorName(20, "COLOR_FormatYUV420PackedPlanar"),
                        new BaseColorName(21, "COLOR_FormatYUV420SemiPlanar"),
                        new BaseColorName(22, "COLOR_FormatYUV422Planar"),
                        new BaseColorName(23, "COLOR_FormatYUV422PackedPlanar"),
                        new BaseColorName(24, "COLOR_FormatYUV422SemiPlanar"),
                        new BaseColorName(25, "COLOR_FormatYCbYCr"),
                        new BaseColorName(26, "COLOR_FormatYCrYCb"),
                        new BaseColorName(27, "COLOR_FormatCbYCrY"),
                        new BaseColorName(28, "COLOR_FormatCrYCbY"),
                        new BaseColorName(29, "COLOR_FormatYUV444Interleaved"),
                        new BaseColorName(30, "COLOR_FormatRawBayer8bit"),
                        new BaseColorName(31, "COLOR_FormatRawBayer10bit"),
                        new BaseColorName(32, "COLOR_FormatRawBayer8bitcompressed"),
                        new BaseColorName(33, "COLOR_FormatL2"),
                        new BaseColorName(34, "COLOR_FormatL4"),
                        new BaseColorName(35, "COLOR_FormatL8"),
                        new BaseColorName(36, "COLOR_FormatL16"),
                        new BaseColorName(37, "COLOR_FormatL24"),
                        new BaseColorName(38, "COLOR_FormatL32"),
                        new BaseColorName(39, "COLOR_FormatYUV420PackedSemiPlanar"),
                        new BaseColorName(40, "COLOR_FormatYUV422PackedSemiPlanar"),
                        new BaseColorName(41, "COLOR_Format18BitBGR666"),
                        new BaseColorName(42, "COLOR_Format24BitARGB6666"),
                        new BaseColorName(43, "COLOR_Format24BitABGR6666"),
                        new BaseColorName(2130706688, "COLOR_TI_FormatYUV420PackedSemiPlanar"),
                        new BaseColorName(2130708361, "COLOR_FormatSurface"),
                        new BaseColorName(2141391872, "COLOR_QCOM_FormatYUV420SemiPlanar")
                });


        public VCNameResolver(String type) {
            this.type = type;
        }

        public String getProfileName(int id) {
            for (BaseProfile profile : profiles) {
                if (profile.getType().equals(this.type)) {
                    return profile.getName(id);
                }
            }
            return null;
        }

        public String getLevelName(int id) {
            for (BaseLevel level : levels) {
                if (level.getType().equals(this.type)) {
                    return level.getName(id);
                }
            }
            return null;
        }

        public String getColorName(int id) {
            return colors.getName(id);
        }
    }
}