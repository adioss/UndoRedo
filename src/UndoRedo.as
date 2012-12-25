package {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.collections.ArrayCollection;
    import mx.controls.TextArea;
    import mx.core.mx_internal;

    public class UndoRedo {
        use namespace mx_internal;

        private var m_commands:ArrayCollection = new ArrayCollection();
        private var m_previous:String = "";
        private var m_currentWord:String = "";
        private var m_currentIndex:int = 0;
        private var m_textArea:TextArea;
        private var m_changedByUndoRedoOperation:Boolean = false;

        public function UndoRedo(textArea:TextArea) {
            m_textArea = textArea;
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_UP, onTextAreaKeyUp);
        }

        private function onTextAreaChanged(event:Event):void {
            if (!m_changedByUndoRedoOperation) {
                var current:String = m_textArea.text;
                var difference:String = StringDifferenceUtils.difference(m_previous, current);
                if (difference == "") {
                    difference = StringDifferenceUtils.difference(current, m_previous);
                }
                if (difference.length == 1) {
                    if (difference == "\n" || difference == "\r" || difference == "\t") {
                        appendCurrentWord();
                        append(difference);
                    } else {
                        m_currentWord += difference;
                    }
                } else {
                    if (m_currentWord != "") {
                        appendCurrentWord();
                    }
                    append(difference);
                }
                m_previous = current;
            }
            m_changedByUndoRedoOperation = false;
        }

        private function append(difference:String):void {
            m_commands.addItemAt(new Difference(getCorrespondingCursorPosition(difference), difference), m_currentIndex);
            m_currentIndex++;
        }

        private function appendCurrentWord():void {
            m_commands.addItemAt(new Difference(getCorrespondingCursorPosition(m_currentWord), m_currentWord), m_currentIndex);
            m_currentWord = "";
            m_currentIndex++;
        }

        private function onTextAreaKeyUp(event:KeyboardEvent):void {
            if (event.ctrlKey && event.keyCode == Keyboard.W) {
                undo();
            } else if (event.ctrlKey && event.shiftKey && event.keyCode == Keyboard.Z) {

            }
        }

        private function undo():void {
            if (m_currentIndex > 0) {
                m_changedByUndoRedoOperation = true;
                m_currentIndex--;
                var difference:Difference = Difference(m_commands.getItemAt(m_currentIndex));
                var text:String = m_textArea.text;
                var s:String = text.slice(0, difference.position + (difference.content.length > 1 ? -1 : 0));
                var s2:String = text.slice(difference.position + difference.content.length, text.length);
                m_textArea.text = s + s2; //\r\u001A
            }
        }

        private function redo():void {
            if (m_currentIndex > 0) {
                m_changedByUndoRedoOperation = true;
            }
        }

        private function getCorrespondingCursorPosition(word:String):int {
            return m_textArea.getTextField().caretIndex - word.length;
        }

        private function getCursorPosition():int {
            return m_textArea.getTextField().caretIndex;
        }

        private static function formatItem(item:String):String {
            return "\"" + item + "\"";
        }

        public function get commands():ArrayCollection {
            return m_commands;
        }
    }
}
