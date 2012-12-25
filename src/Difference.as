package {
    public class Difference {
        private var m_position:int;
        private var m_content:String;

        public function Difference(position:int, content:String) {
            m_position = position;
            m_content = content;
        }

        private static function formatItem(item:String):String {
            return "\"" + item + "\"";
        }

        public function toString():String {
            return "Difference{m_position=" + String(m_position) + ",m_content=" + formatItem(String(m_content)) + "}";
        }
    }
}
