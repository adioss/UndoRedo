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
            if (isUndoKeyPressed(event)) {
                undo();
            } else if (isRedoKeyPressed(event)) {

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
                        if (isNewLineOrTab(difference.content)) {
                            appendCurrentDifferences(difference);
                        } else {
                            m_currentWord += difference.content;
                        }
                    } else {
                        appendCurrentWord();
                        append(difference);
                    }
                } else { // deletion management
                    append(difference);
                }
                m_previousText = currentText;
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

        private function undo():void {
            if (currentIndex > 0) {
                appendCurrentWord(0);
                m_isChangedByUndoRedoOperation = true;
                currentIndex--;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                var textField:String = m_textArea.getTextField().text;
                var beginPart:String = textField.slice(0, difference.position);
                var endPart:String = textField.slice(difference.position + difference.content.length, textField.length);
                m_textArea.callLater(setTextAreaContent, [beginPart + endPart, difference.position]);
            }
        }

        private function redo():void {
            if (currentIndex > 0) {
                m_isChangedByUndoRedoOperation = true;
            }
        }

        private function appendCurrentDifferences(difference:Difference):void {
            appendCurrentWord();
            append(difference);
        }

        private function append(difference:Difference):void {
            appendItem(difference);
            currentIndex++;
        }

        private function appendCurrentWord(delta:int = -1):void {
            if (m_currentWord != "") {
                var cursorPosition:int = getCorrespondingCursorPosition(m_currentWord, delta);
                var difference:Difference = new Difference(cursorPosition, m_currentWord, Difference.ADDITION_DIFFERENCE_TYPE);
                appendItem(difference);
                m_currentWord = "";
                currentIndex++;
            }
        }

        private function appendItem(difference:Difference):void {
            if (commands.length > currentIndex) {
                commands = new ArrayCollection(commands.toArray().slice(0, currentIndex));
            }
            commands.addItemAt(difference, currentIndex);
        }

        private function setTextAreaContent(content:String, focusPosition:int):void {
            m_textArea.text = m_previousText = content;
            m_textArea.callLater(extracted, [focusPosition]);
        }

        private function extracted(focusPosition:int):void {
            m_textArea.setSelection(focusPosition, focusPosition);
            m_textArea.setFocus();
        }

        private function getCorrespondingCursorPosition(word:String, delta:int = -1):int {
            return m_textArea.getTextField().caretIndex - word.length + delta;
        }

        private static function isUndoKeyPressed(event:KeyboardEvent):Boolean {
            //return event.ctrlKey && event.keyCode == Keyboard.W; // pb in mac
            return event.ctrlKey && event.keyCode == Keyboard.Z;
        }

        private static function isRedoKeyPressed(event:KeyboardEvent):Boolean {
            return event.ctrlKey && event.shiftKey && event.keyCode == Keyboard.Z;
        }

        private static function isNewLineOrTab(content:String):Boolean {
            return content == "\n" || content == "\t" || content == "\r";
        }
    }
}
