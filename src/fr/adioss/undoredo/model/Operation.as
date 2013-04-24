package fr.adioss.undoredo.model {
    /**
     * Class to represent a 'diff operation'.  A diff operation
     * can be one of an equality, insertion, or deletion, accompanied
     * by the relevant text.
     *
     * @author Charles Bihis (www.whoischarles.com)
     */
    public class Operation {
        public static const EQUAL:String = "EQUAL";
        public static const INSERT:String = "INSERT";
        public static const DELETE:String = "DELETE";

        public var type:String;
        public var content:String;

        /**
         * Constructor.
         *
         * @param op The operation of this particular diff.
         * @param content The relevant text for this particular diff.
         */
        public function Operation(op:String, content:String) {
            this.type = op;
            this.content = content;
        }

        /**
         * Override of parent toString() method.
         *
         * @return A human-readable string representing a diff operation.
         */
        public function toString():String {
            return "[" + type + "] " + content;
        }
    }
}
