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
        private var m_textArea:TextArea;
        private var m_isChangedByUndoRedoOperation:Boolean = false;
        private var m_isManagedByKeyBoardEvents:Boolean = false;

        [Bindable]
        public var commands:ArrayCollection = new ArrayCollection();
        [Bindable]
        public var currentIndex:int = 0;

        public function UndoRedo(textArea:TextArea) {
            m_textArea = textArea;
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_DOWN, onTextAreaKeyDown);
        }

        //region Events
        private function onTextAreaKeyDown(event:KeyboardEvent):void {
            if (event.ctrlKey && event.keyCode == Keyboard.W) {
                undo();
            } else if (event.ctrlKey && event.shiftKey && event.keyCode == Keyboard.Z) {

            } else if (event.keyCode == Keyboard.BACKSPACE || event.keyCode == Keyboard.DELETE) {
                m_textArea.callLater(manageBackspaceOnKeyPressed); // line break deletion not detected by text area changes...
            }
        }

        private function onTextAreaChanged(event:Event):void {
            if (!m_isChangedByUndoRedoOperation) {
                var currentText:String = m_textArea.text;
                manageTextDifferences(currentText, StringDifferenceUtils.difference(m_previousText, currentText));
            }
            m_isChangedByUndoRedoOperation = m_isManagedByKeyBoardEvents = false;
        }

        //endregion

        private function manageTextDifferences(currentText:String, difference:Difference):void {
            if (difference != null && difference.content != "") {
                if (difference.type == Difference.ADDITION_DIFFERENCE_TYPE) { // addition management
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
                } else { // deletion management
                    append(difference);
                }
                m_previousText = currentText;
            }
        }

        private function append(difference:Difference):void {
            commands.addItemAt(difference, currentIndex);
            currentIndex++;
        }

        private function appendCurrentWord():void {
            if (m_currentWord != "") {
                var cursorPosition:int = getCorrespondingCursorPosition(m_currentWord);
                var difference:Difference = new Difference(cursorPosition, m_currentWord, Difference.ADDITION_DIFFERENCE_TYPE);
                commands.addItemAt(difference, currentIndex);
                m_currentWord = "";
                currentIndex++;
            }
        }

        private function undo():void {
            if (currentIndex > 0) {
                m_isChangedByUndoRedoOperation = true;
                currentIndex--;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                var textField:String = m_textArea.getTextField().text;
                var beginPart:String = textField.slice(0, difference.position + (difference.content.length > 1 ? -1 : 0));
                var endPart:String = textField.slice(difference.position + difference.content.length, textField.length);
                m_textArea.text = beginPart + endPart;
            }
        }

        private function redo():void {
            if (currentIndex > 0) {
                m_isChangedByUndoRedoOperation = true;
            }
        }

        private function manageBackspaceOnKeyPressed():void {
            var currentText:String = m_textArea.getTextField().text;
            var difference:Difference = StringDifferenceUtils.difference(m_previousText, currentText);
            if (difference != null && isNewLineOrTab(difference.content)) {
                manageTextDifferences(currentText, difference);
                m_isManagedByKeyBoardEvents = true;
            }
        }

        private function getCorrespondingCursorPosition(word:String):int {
            return m_textArea.getTextField().caretIndex - word.length;
        }

        private static function isNewLineOrTab(content:String):Boolean {
            return content == "\n" || content == "\t" || content == "\r";
        }
    }
}
