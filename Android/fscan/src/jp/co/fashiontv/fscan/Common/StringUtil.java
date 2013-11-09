package jp.co.fashiontv.fscan.Common;

import java.util.Random;

/**
 * Created by Alsor Zhou on 13-11-9.
 */
public class StringUtil {
    /**
     * Generate random string with specific length
     *
     * http://stackoverflow.com/a/12116194
     *
     * @param len random string length
     * @return random string
     */
    public static String randomString(int len) {
        Random generator = new Random();
        StringBuilder randomStringBuilder = new StringBuilder();
        int randomLength = generator.nextInt(len);
        char tempChar;
        for (int i = 0; i < randomLength; i++){
            tempChar = (char) (generator.nextInt(96) + 32);
            randomStringBuilder.append(tempChar);
        }
        return randomStringBuilder.toString();
    }

    /**
     * Generate 8 character string as filename
     *
     * @return filename
     */
    public static String randomFilename() {
        return randomString(8);
    }

    /**
     * Check if url is malform
     * @param url
     * @return
     */
    public static boolean malformUrl(String url) {
        // TODO : "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return true;
    }
}
