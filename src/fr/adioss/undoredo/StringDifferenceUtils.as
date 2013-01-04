package fr.adioss.undoredo {
    import fr.adioss.undoredo.model.Difference;

    public class StringDifferenceUtils {

        public static function difference(original:String, modified:String):Difference {
            var delta:String;
            if (original == modified) {
                return null;
            }
            if (original == null || modified == null) {
                return null;
            }
            var firstGapIndex:int;
            for (firstGapIndex = 0; firstGapIndex < original.length && firstGapIndex < modified.length; ++firstGapIndex) {
                if (original.charAt(firstGapIndex) != modified.charAt(firstGapIndex)) {
                    break;
                }
            }
            var textAfterGapForOriginal:String = original.slice(firstGapIndex, original.length);
            var textAfterGapForModified:String = modified.slice(firstGapIndex, modified.length);
            var indexOfEndGapInModified:int = textAfterGapForModified.indexOf(textAfterGapForOriginal);
            if (indexOfEndGapInModified != -1) { // addition of content
                delta = textAfterGapForModified.slice(0, indexOfEndGapInModified);
                if (delta != "") {
                    return new Difference(firstGapIndex, delta, Difference.ADDITION_DIFFERENCE_TYPE);
                } else {
                    return new Difference(firstGapIndex, textAfterGapForModified, Difference.ADDITION_DIFFERENCE_TYPE);
                }
            } else {
                if (textAfterGapForModified != "") {
                    var indexOfEndGapInOriginal:int = original.indexOf(textAfterGapForModified);
                    delta = original.slice(firstGapIndex, indexOfEndGapInOriginal);
                    return new Difference(firstGapIndex, delta, Difference.SUBTRACTION_DIFFERENCE_TYPE);
                } else {
                    return new Difference(firstGapIndex, textAfterGapForOriginal, Difference.SUBTRACTION_DIFFERENCE_TYPE);
                }

            }
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
