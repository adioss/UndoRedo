package fr.adioss.undoredo {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.text.TextField;
    import flash.ui.Keyboard;

    import fr.adioss.undoredo.model.Difference;
    import fr.adioss.undoredo.model.ProcessedWord;

    import mx.collections.ArrayCollection;
    import mx.controls.TextArea;
    import mx.core.mx_internal;

    public class UndoRedo {
        use namespace mx_internal;

        private var m_previousText:String = "";
        private var m_currentProcessedWord:ProcessedWord;
        private var m_textArea:TextArea;
        private var m_textField:TextField;
        private var m_isChangedByUndoRedoOperation:Boolean = false;

        [Bindable]
        public var commands:ArrayCollection = new ArrayCollection();
        [Bindable]
        public var currentIndex:int = 0;

        public function UndoRedo(textArea:TextArea) {
            m_textArea = textArea;
            m_textField = TextField(m_textArea.getTextField());
            m_textArea.addEventListener(Event.CHANGE, onTextAreaChanged);
            m_textArea.addEventListener(KeyboardEvent.KEY_DOWN, onTextAreaKeyDown);
        }

        //region Events
        private function onTextAreaKeyDown(event:KeyboardEvent):void {
            if (isUndoKeyPressed(event)) {
                undo();
            } else if (isRedoKeyPressed(event)) {
                redo();
            } else if (event.keyCode == Keyboard.BACKSPACE || event.keyCode == Keyboard.DELETE) {
                m_textArea.callLater(manageBackspaceOnKeyPressed); // line break deletion not detected by text area changes...
            }
        }

        private function onTextAreaChanged(event:Event):void {
            if (!m_isChangedByUndoRedoOperation) {
                var currentText:String = escapeSubstituteCharsOnTextField(m_textField);
                var previousText:String = escapeSubstituteChars(m_previousText);
                if (currentText != "") {
                    manageTextDifferences(currentText, StringDifferenceUtils.difference(previousText, currentText));
                }
            }
            m_isChangedByUndoRedoOperation = false;
        }

        //endregion

        private function manageTextDifferences(currentText:String, difference:Difference):void {
            if (difference != null && difference.content != "") {
                if (difference.type == Difference.ADDITION_DIFFERENCE_TYPE) { // addition management
                    if (difference.content.length == 1) {
                        if (isNewLineOrTab(difference.content)) {
                            appendCurrentDifferences(difference);
                        } else {
                            appendInProcessedWord(difference.content);
                        }
                    } else {
                        appendCurrentDifferences(difference);
                    }
                } else { // deleton management
                    appendCurrentDifferences(difference);
                }
                m_previousText = currentText;
            }
        }

        private function appendInProcessedWord(content:String):void {
            if (m_currentProcessedWord == null) {
                m_currentProcessedWord = new ProcessedWord(content, getCorrespondingCursorPosition(content, 0));
            } else {
                m_currentProcessedWord.content += content;
            }
        }

        private function manageBackspaceOnKeyPressed():void {
            var currentText:String = m_textField.text;
            var difference:Difference = StringDifferenceUtils.difference(m_previousText, currentText);
            if (difference != null && isNewLineOrTab(difference.content)) {
                manageTextDifferences(currentText, difference);
            }
        }

        private function undo():void {
            if (currentIndex > 0) {
                appendCurrentWord();
                m_isChangedByUndoRedoOperation = true;
                currentIndex--;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                if (difference.type == Difference.SUBTRACTION_DIFFERENCE_TYPE) {
                    m_textArea.callLater(modifyTextAreaContent, [difference.content, difference.position , difference.position]);
                } else {
                    m_textArea.callLater(modifyTextAreaContent, ["", difference.position, difference.position + difference.content.length]);
                }
            }
        }

        private function redo():void {
            if (currentIndex < commands.length) {
                m_isChangedByUndoRedoOperation = true;
                var difference:Difference = Difference(commands.getItemAt(currentIndex));
                if (difference.type == Difference.SUBTRACTION_DIFFERENCE_TYPE) {
                    m_textArea.callLater(modifyTextAreaContent, ["", difference.position, difference.position + difference.content.length]);
                } else {
                    m_textArea.callLater(modifyTextAreaContent, [difference.content, difference.position , difference.position]);
                }
                currentIndex++;
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

        private function appendCurrentWord():void {
            if (m_currentProcessedWord != null && m_currentProcessedWord.content != "") {
                var difference:Difference = new Difference(m_currentProcessedWord.initialPosition, m_currentProcessedWord.content,
                                                           Difference.ADDITION_DIFFERENCE_TYPE);
                appendItem(difference);
                m_currentProcessedWord = null;
                currentIndex++;
            }
        }

        private function appendItem(difference:Difference):void {
            if (commands.length > currentIndex) {
                commands = new ArrayCollection(commands.toArray().slice(0, currentIndex));
            }
            commands.addItemAt(difference, currentIndex);
        }

        private function modifyTextAreaContent(content:String, beginIndex:int, endIndex:int):void {
            m_textField.replaceText(beginIndex, endIndex, content);
            m_previousText = m_textField.text;
        }

        private function getCorrespondingCursorPosition(word:String, delta:int = -1):int {
            var caretIndex:int = m_textField.caretIndex;
            return caretIndex - word.length + delta;
        }

        private static function escapeSubstituteCharsOnTextField(textField:TextField):String {
            var result:String = textField.text;
            result = escapeSubstituteChars(result);
            textField.text = result; // sorry for this...
            return result;
        }

        private static function escapeSubstituteChars(result:String):String {
            return result.replace(/["\u001A"]+/g, "");
        }

        private static function isUndoKeyPressed(event:KeyboardEvent):Boolean {
            return event.ctrlKey && !event.shiftKey && event.keyCode == Keyboard.W; // pb in mac
            //return event.ctrlKey && event.keyCode == Keyboard.Z;
        }

        private static function isRedoKeyPressed(event:KeyboardEvent):Boolean {
            //return event.ctrlKey && event.shiftKey && event.keyCode == Keyboard.Z;
            return event.ctrlKey && event.shiftKey && event.keyCode == Keyboard.W;
        }

        private static function isNewLineOrTab(content:String):Boolean {
            return content == "\n" || content == "\t" || content == "\r";
        }
    }
}
