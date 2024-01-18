

## TODO
- [+] add console log with MediaCodecListInfo
- [ ] maybe add MediaCodecListCollector
- [ ] refactor to  

To refactor the printCodecsNamed() method from your MainActivity class into another Java file, you need to follow these steps:

# Step 1: Create a new Java class
First, create a new Java file for the class that will contain the printCodecsNamed() method. You can name this class CodecInfoPrinter or any other name you prefer.




public class CodecInfoPrinter {
    private String textBoxString;

    public CodecInfoPrinter() {
        // Constructor can be empty or can initialize variables if needed
    }

    public void printCodecsNamed() {
        // Method implementation (copy the body from MainActivity's printCodecsNamed)
    }

    // Additional methods or logic if necessary
}
# Step 2: Copy the printCodecsNamed() method
Copy the printCodecsNamed() method from the MainActivity class into the CodecInfoPrinter class you've just created.




`public class CodecInfoPrinter {
    private String textBoxString;

    public CodecInfoPrinter() {
        // Initialize the textBoxString or other variables if needed
    }

    public void printCodecsNamed() {
        // Copy the implementation of printCodecsNamed from MainActivity here
    }

    // Additional methods or logic if necessary
}`
Make sure you also copy any necessary imports at the top of the file:




`import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.util.Log;`
# Step 3: Adjust the method to fit the new class
If the printCodecsNamed() method uses any member variables or methods from MainActivity that aren't present in CodecInfoPrinter, you'll need to adjust the code. For example, if it references a variable like textBoxString, make sure that's declared in the CodecInfoPrinter class.

# Step 4: Update MainActivity
In your MainActivity, you'll now use an instance of CodecInfoPrinter to call the printCodecsNamed() method. Remove or comment out the original printCodecsNamed() method in MainActivity to prevent duplicate definitions.




`@Override
protected void onCreate(Bundle savedInstanceState) {
    // ... other initialization ...

    CodecInfoPrinter codecInfoPrinter = new CodecInfoPrinter();
    codecInfoPrinter.printCodecsNamed();

    // ... rest of your onCreate ...
}`
# Step 5: Handle dependencies
Ensure that CodecInfoPrinter has access to any resources it needs that were originally provided by MainActivity. This might include context, resources, or other dependencies.

If needed, you can modify the constructor of CodecInfoPrinter to accept parameters:




`public class CodecInfoPrinter {
    private Context context;
    private String textBoxString;

    public CodecInfoPrinter(Context context) {
        this.context = context;
        // Initialize other variables if needed
    }

    public void printCodecsNamed() {
        // Method implementation
    }
}`
And then in MainActivity:




`@Override
protected void onCreate(Bundle savedInstanceState) {
    // ... other initialization ...

    CodecInfoPrinter codecInfoPrinter = new CodecInfoPrinter(this); // Pass the context
    codecInfoPrinter.printCodecsNamed();

    // ... rest of your onCreate ...
}`

# Step 6: Test
After refactoring, test your application to ensure that the printCodecsNamed() method still works as expected in its new location. Debug and fix any issues that arise from the move.

Remember that when you move methods around, especially from an Android Activity to another class, you often have to deal with issues related to the Android context, lifecycle, and permissions. Make sure to handle these appropriately in your new class.

https://github.com/ACRA/acra/blob/master/acra-core/src/main/java/org/acra/collector/MediaCodecListCollector.kt


## Suported codecs log output:


`Total Number of Codecs are : 69
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 0 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.aac.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/mp4a-latm 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 5, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 29, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 23, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 39, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 20, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 42, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 1 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.aac.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/mp4a-latm 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 5, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 29, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 23, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 39, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 20, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 42, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 2 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.aac.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/mp4a-latm 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 5, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 29, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 23, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 39, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 3 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.aac.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/mp4a-latm 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 5, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 29, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 23, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 39, Level: 0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 4 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.amrnb.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 5 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.amrnb.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 6 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.amrnb.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 7 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.amrnb.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 8 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.amrwb.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/amr-wb 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 9 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.amrwb.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/amr-wb 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 10 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.amrwb.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/amr-wb 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 11 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.amrwb.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/amr-wb 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 12 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.flac.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/flac 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 13 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.flac.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/flac 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 14 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.flac.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/flac 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 15 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.flac.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/flac 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 16 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.g711.alaw.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/g711-alaw 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 17 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.g711.alaw.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/g711-alaw 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 18 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.g711.mlaw.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/g711-mlaw 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 19 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.g711.mlaw.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/g711-mlaw 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 20 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.gsm.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/gsm 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 21 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.gsm.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/gsm 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 22 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.mp3.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/mpeg 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 23 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.mp3.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/mpeg 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 24 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.opus.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/opus 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 25 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.opus.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/opus 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 26 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.opus.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/opus 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 27 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.raw.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/raw 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 28 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.raw.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/raw 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 29 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.vorbis.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/vorbis 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 30 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.vorbis.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : audio/vorbis 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 31 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.avc.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileHigh, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 32 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.decoder.avc
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileHigh, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 33 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.avc.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileHigh, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 34 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.encoder.avc
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileHigh, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 35 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.hevc.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 36 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.decoder.hevc
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 37 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.hevc.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 38 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.encoder.hevc
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 2, Level: 33554432
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 39 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.vp8.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 40 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.decoder.vp8
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 41 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.vp8.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 42 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.encoder.vp8
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 16
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 43 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.qti.vp9.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp9 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 6
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 44 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.qcom.video.decoder.vp9
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp9 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 6
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 45 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.av1.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/av01 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 32768
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 32768
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 8192, Level: 32768
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 46 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.avc.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 524288, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileHigh, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 47 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.h264.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 524288, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileHigh, Level: 65536
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 48 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.avc.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: AVCLevel5
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: AVCLevel5
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: AVCLevel5
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 49 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.h264.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/avc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileBaseline, Level: AVCLevel5
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 65536, Level: AVCLevel5
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: AVCProfileMain, Level: AVCLevel5
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 50 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.h263.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level45
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level40
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileISWV2, Level: H263Level45
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileISWV2, Level: H263Level40
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 51 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.h263.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level45
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level40
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileISWV2, Level: H263Level45
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileISWV2, Level: H263Level40
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 52 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.h263.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level45
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level40
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 53 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.h263.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/3gpp 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level45
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: H263ProfileBaseline, Level: H263Level40
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 54 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.hevc.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 524288
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 524288
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 55 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.hevc.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 524288
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 524288
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 56 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.hevc.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/hevc 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 262144
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 262144
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 57 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.mpeg4.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/mp4v-es 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: MPEG4ProfileSimple, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 58 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.mpeg4.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/mp4v-es 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: MPEG4ProfileSimple, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 59 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.mpeg4.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/mp4v-es 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: MPEG4ProfileSimple, Level: MPEG4Level2
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 60 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.mpeg4.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/mp4v-es 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: MPEG4ProfileSimple, Level: MPEG4Level2
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 61 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.vp8.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 62 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.vp8.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 63 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.vp8.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 64 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.vp8.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp8 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: VP8ProfileMain, Level: VP8Level_Version0
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 65 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.vp9.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp9 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 16384, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 66 ( Decoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.vp9.decoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp9 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 4096, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 16384, Level: 256
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 67 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: c2.android.vp9.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp9 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 128
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: 
01-18 14:13:51.524 26352 26352 D agdkeframe: Codec : 68 ( Encoder)
01-18 14:13:51.524 26352 26352 D agdkeframe: Name: OMX.google.vp9.encoder
01-18 14:13:51.524 26352 26352 D agdkeframe: Types : ( 1 )
01-18 14:13:51.524 26352 26352 D agdkeframe:  For Type : video/x-vnd.on2.vp9 
01-18 14:13:51.524 26352 26352 D agdkeframe:  Color Formats: 
01-18 14:13:51.524 26352 26352 D agdkeframe:    2135033992,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420Planar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420SemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatYUV420PackedSemiPlanar,
01-18 14:13:51.524 26352 26352 D agdkeframe:    COLOR_FormatSurface,
01-18 14:13:51.524 26352 26352 D agdkeframe: Profile: 1, Level: 128
01-18 14:13:51.524 26352 26352 D agdkeframe: Maximum Instances: 32`