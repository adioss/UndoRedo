package {
    public class StringDifferenceUtils {
        public static var INDEX_NOT_FOUND:int = -1;
        public static var EMPTY:String = "";

        public function StringDifferenceUtils() {
        }

        public static function difference(str1:String, str2:String):String {
            if (str1 == null) {
                return str2;
            }
            if (str2 == null) {
                return str1;
            }
            var at:int = indexOfDifference(str1, str2);
            if (at == INDEX_NOT_FOUND) {
                return EMPTY;
            }
            return str2.substring(at);
        }

        public static function indexOfDifference(str1:String, str2:String):int {
            if (str1 == str2) {
                return INDEX_NOT_FOUND;
            }
            if (str1 == null || str2 == null) {
                return 0;
            }
            var i:int;
            for (i = 0; i < str1.length && i < str2.length; ++i) {
                if (str1.charAt(i) != str2.charAt(i)) {
                    break;
                }
            }
            if (i < str2.length || i < str1.length) {
                return i;
            }
            return INDEX_NOT_FOUND;
        }

        public static function levenshteinDistance(str1:String, str2:String):int {
            var str1Length:int = str1.length;
            var str2Length:int = str2.length;
            var matrix:Array = [];
            var line:Array;
            var i:int;
            var j:int;
            for (i = 0; i <= str1Length; i++) {
                line = [];
                for (j = 0; j <= str2Length; j++) {
                    if (i != 0) {
                        line.push(0)
                    } else {
                        line.push(j);
                    }
                }
                line[0] = i;
                matrix.push(line);
            }
            var cost:int;
            for (i = 1; i <= str1Length; i++) {
                for (j = 1; j <= str2Length; j++) {
                    if (str1.charAt(i - 1) == str2.charAt(j - 1)) {
                        cost = 0
                    } else {
                        cost = 1;
                    }
                    matrix[i][j] = Math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost);
                }
            }
            return matrix[str1Length][str2Length];
        }
    }
}
