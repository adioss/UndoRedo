package fr.adioss.undoredo.model {
    public class Difference {
        public static const ADDITION_DIFFERENCE_TYPE:String = "ADDITION_DIFFERENCE_TYPE";
        public static const SUBTRACTION_DIFFERENCE_TYPE:String = "SUBTRACTION_DIFFERENCE_TYPE";

        private var m_position:int;
        private var m_content:String;
        private var m_type:String;

        public function Difference(position:int, content:String, type:String) {
            m_position = position;
            m_content = content;
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

        public function get content():String {
            return m_content;
        }

        public function set content(value:String):void {
            m_content = value;
        }

        public function get type():String {
            return m_type;
        }

        public function set type(value:String):void {
            m_type = value;
        }

        public function toString():String {
            return "Difference{m_position=" + String(m_position) + ",m_content=" + formatItem(String(m_content)) + ",m_type=" + String(m_type) + "}";
        }
    }
}
