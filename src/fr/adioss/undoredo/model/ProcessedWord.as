package fr.adioss.undoredo.model {
    public class ProcessedWord {
        private var m_initialPosition:int;
        private var m_content:String;

        public function ProcessedWord(content:String, position:int) {
            m_initialPosition = position;
            m_content = content;
        }

        public function get initialPosition():int {
            return m_initialPosition;
        }

        public function get content():String {
            return m_content;
        }

        public function set content(value:String):void {
            m_content = value;
        }

    }
}
