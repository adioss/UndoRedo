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
    }
}
