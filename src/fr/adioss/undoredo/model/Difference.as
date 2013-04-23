package fr.adioss.undoredo.model {
    public class Difference {
        public static const ADDITION_DIFFERENCE_TYPE:String = "ADDITION_DIFFERENCE_TYPE";
        public static const SUBTRACTION_DIFFERENCE_TYPE:String = "SUBTRACTION_DIFFERENCE_TYPE";
        public static const COMPLEX_DIFFERENCE_TYPE:String = "COMPLEX_DIFFERENCE_TYPE";

        private var m_position:int;
        private var m_originalContentAfterPosition:String;
        private var m_type:String;

        public function Difference(position:int, content:String, type:String) {
            m_position = position;
            m_originalContentAfterPosition = content;
            m_type = type;
        }

        private static function formatItem(item:String):String {
            return "\"" + item + "\"";
        }

        public function get position():int {
            return m_position;
        }

        public function set position(value:int):void {
            m_position = value;
        }

        public function get originalContentAfterPosition():String {
            return m_originalContentAfterPosition;
        }

        public function set originalContentAfterPosition(value:String):void {
            m_originalContentAfterPosition = value;
        }

        public function get type():String {
            return m_type;
        }

        public function set type(value:String):void {
            m_type = value;
        }

        public function toString():String {
            return "Difference{m_position=" + String(m_position) + ",m_originalContentAfterPosition=" + formatItem(String(m_originalContentAfterPosition))
                    + ",m_type=" + String(m_type) + "}";
        }
    }
}
