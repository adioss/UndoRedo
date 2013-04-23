package fr.adioss.undoredo.model {
    public class ComplexDifference extends Difference {
        private var m_modifiedContentAfterPosition:String;

        public function ComplexDifference(position:int, originalContentAfterPosition:String, modifiedContentAfterPosition:String) {
            super(position, originalContentAfterPosition, COMPLEX_DIFFERENCE_TYPE);
            m_modifiedContentAfterPosition = modifiedContentAfterPosition;
        }

        public function get modifiedContentAfterPosition():String {
            return m_modifiedContentAfterPosition;
        }

        public function set modifiedContentAfterPosition(value:String):void {
            m_modifiedContentAfterPosition = value;
        }
    }
}
