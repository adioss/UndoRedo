package fr.adioss.undoredo {
    import fr.adioss.undoredo.model.ComplexDifference;
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
            for (firstGapIndex = 0; firstGapIndex < original.length && firstGapIndex < modified.length; firstGapIndex++) {
                if (original.charAt(firstGapIndex) != modified.charAt(firstGapIndex)) {
                    break;
                }
            }
            var textAfterGapForOriginal:String = original.slice(firstGapIndex, original.length);
            var textAfterGapForModified:String = modified.slice(firstGapIndex, modified.length);
            var indexOfEndGapInModified:int = textAfterGapForModified.indexOf(textAfterGapForOriginal);
            var indexOfEndGapInOriginal:int = textAfterGapForOriginal.indexOf(textAfterGapForModified);
            if (indexOfEndGapInModified != -1) { // addition of content
                delta = textAfterGapForModified.slice(0, indexOfEndGapInModified);
                if (delta != "") {
                    return new Difference(firstGapIndex, delta, Difference.ADDITION_DIFFERENCE_TYPE);
                } else {
                    return new Difference(firstGapIndex, textAfterGapForModified, Difference.ADDITION_DIFFERENCE_TYPE);
                }
            } else if (indexOfEndGapInOriginal != -1) { //
                if (textAfterGapForModified != "") {
                    delta = original.slice(firstGapIndex, firstGapIndex + indexOfEndGapInOriginal);
                    return new Difference(firstGapIndex, delta, Difference.SUBTRACTION_DIFFERENCE_TYPE);
                } else {
                    return new Difference(firstGapIndex, textAfterGapForOriginal, Difference.SUBTRACTION_DIFFERENCE_TYPE);
                }
            } else { // multiple differences
                return new ComplexDifference(firstGapIndex, textAfterGapForOriginal, textAfterGapForModified);
            }
        }

    }
}
