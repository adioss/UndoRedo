package {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.collections.ArrayCollection;
    import mx.controls.TextArea;
    import mx.core.mx_internal;

    public class UndoRedo {
        use namespace mx_internal;

        private var m_previousText:String = "";
        private var m_currentWord:String = "";
        private var m_currentIndex:int = 0;
        private var m_textArea:TextArea;
        private var m_isChangedByUndoRedoOperation:Boolean = false;

        [Bindable]
        public var commands:ArrayCollection = new ArrayCollection();

        public function UndoRedo(textArea:TextArea) {
            m_textArea = textArea;
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_UP, onTextAreaKeyUp);
        }

        //region Events
        private function onTextAreaKeyUp(event:KeyboardEvent):void {
            if (event.ctrlKey && event.keyCode == Keyboard.W) {
                undo();
            } else if (event.ctrlKey && event.shiftKey && event.keyCode == Keyboard.Z) {

            }
        }

        private function onTextAreaChanged(event:Event):void {
            if (!m_isChangedByUndoRedoOperation) {
                manageTextChanges(m_textArea.text);
            }
            m_isChangedByUndoRedoOperation = false;
        }

        //endregion

        private function manageTextChanges(currentText:String):void {
            var difference:Difference = StringDifferenceUtils.difference(m_previousText, currentText);
            if (difference.content != "") {
                if (difference.type == Difference.ADDITION_DIFFERENCE_TYPE) {
                    if (difference.content.length == 1) {
                        if (difference.content == "\n" || difference.content == "\r" || difference.content == "\t") {
                            appendCurrentWord();
                            append(difference);
                        } else {
                            m_currentWord += difference.content;
                        }
                    } else {
                        if (m_currentWord != "") {
                            appendCurrentWord();
                        }
                        append(difference);
                    }
                } else {
                    if (difference.content.length == 1) {
                        appendCurrentWord();
                        append(difference);
                    }
                }
                m_previousText = currentText;
            }
        }

        private function append(difference:Difference):void {
            commands.addItemAt(difference, m_currentIndex);
            m_currentIndex++;
        }

        private function appendCurrentWord():void {
            commands.addItemAt(new Difference(getCorrespondingCursorPosition(m_currentWord), m_currentWord, Difference.ADDITION_DIFFERENCE_TYPE),
                               m_currentIndex);
            m_currentWord = "";
            m_currentIndex++;
        }

        private function undo():void {
            if (m_currentIndex > 0) {
                m_isChangedByUndoRedoOperation = true;
                m_currentIndex--;
                var difference:Difference = Difference(commands.getItemAt(m_currentIndex));
                var text:String = m_textArea.text;
                var s:String = text.slice(0, difference.position + (difference.content.length > 1 ? -1 : 0));
                var s2:String = text.slice(difference.position + difference.content.length, text.length);
                m_textArea.text = s + s2; //\r\u001A
            }
        }

        private function redo():void {
            if (m_currentIndex > 0) {
                m_isChangedByUndoRedoOperation = true;
            }
        }

        private function getCorrespondingCursorPosition(word:String):int {
            return m_textArea.getTextField().caretIndex - word.length;
        }
    }
}
